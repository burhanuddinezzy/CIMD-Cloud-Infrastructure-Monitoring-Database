import time
import json
import psycopg2
from dotenv import load_dotenv
import os  # Missing import for os

load_dotenv()

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "database": "postgres",
    "user": "postgres",
    "password": os.environ.get("TELE_POSTGRES_PASS"),
}

METRICS_FILE = "/tmp/telegraf_metrics.json"
REQUIRED_FIELDS = ["server_id", "location_id", "timestamp", "cpu_usage", "memory_usage"]

metrics_buffer = {}
latest_timestamp_seen = None
written_timestamps = set()
previous_diskio = {}  # Add this at the top of your script
previous_net = {}

def insert_row(row):
    try:
        print("🟢 Attempting to insert row with values:")
        for k, v in row.items():
            print(f"    {k}: {v}")
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO server_metrics (
                server_id, location_id, timestamp, cpu_usage, memory_usage, disk_usage_percent,
                disk_read_ops_per_sec, disk_write_ops_per_sec, disk_read_throughput,
                disk_write_throughput, network_in_bytes, network_out_bytes, latency_in_ms,
                uptime_in_mins, error_count
            ) VALUES (
                %(server_id)s, %(location_id)s, to_timestamp(%(timestamp)s), %(cpu_usage)s, %(memory_usage)s, %(disk_usage_percent)s,
                %(disk_read_ops_per_sec)s, %(disk_write_ops_per_sec)s, %(disk_read_throughput)s,
                %(disk_write_throughput)s, %(network_in_bytes)s, %(network_out_bytes)s, %(latency_in_ms)s,
                %(uptime_in_mins)s, %(error_count)s
            )
        """, row)
        conn.commit()
        cur.close()
        conn.close()
        print(f"✅ Inserted row for timestamp {row['timestamp']}")
    except Exception as e:
        print("❌ Insert error:", e)
        print("Row:", row)

def is_row_complete(row):
    complete = all(row.get(field) is not None for field in REQUIRED_FIELDS)
    if not complete:
        print("⚠️ Skipping incomplete row (missing required fields):")
        for k in REQUIRED_FIELDS:
            print(f"    {k}: {row.get(k)}")
        print("Full row buffer:", json.dumps(row, indent=2))
    return complete

def parse_metric_line(line):
    global latest_timestamp_seen

    if not line.strip():
        return

    try:
        metric = json.loads(line)
        fields = metric.get("fields", {})
        tags = metric.get("tags", {})
        ts = metric.get("timestamp")

        if ts is None:
            return

        if ts not in metrics_buffer:
            metrics_buffer[ts] = {
                "server_id": tags.get("server_id"),
                "location_id": tags.get("location_id"),
                "timestamp": ts / 1e9 if ts > 1e12 else ts if ts else None,  # convert ns to s
                "cpu_usage": None,
                "memory_usage": None,
                "disk_usage_percent": None,
                "disk_read_ops_per_sec": None,
                "disk_write_ops_per_sec": None,
                "disk_read_throughput": None,
                "disk_write_throughput": None,
                "network_in_bytes": None,
                "network_out_bytes": None,
                "latency_in_ms": None,
                "uptime_in_mins": None,
                "error_count": None
            }

        row = metrics_buffer[ts]

        # Merge metrics
        name = metric.get("name")
        if name == "cpu" and tags.get("cpu") == "cpu-total":
            # Use usage_active if present, else calculate from usage_idle
            if "usage_active" in fields:
                row["cpu_usage"] = fields.get("usage_active")
            elif "usage_idle" in fields:
                row["cpu_usage"] = 100 - fields.get("usage_idle")
            else:
                row["cpu_usage"] = 0
        elif name == "mem":
            row["memory_usage"] = fields.get("used_percent_mem")
        elif name == "disk" and tags.get("path") == "/":
            row["disk_usage_percent"] = fields.get("disk_usage_percent")
        elif name == "diskio":
            device = tags.get("name")
            if device in ("sda", "sda1"):
                reads = fields.get("reads")
                writes = fields.get("writes")
                read_bytes = fields.get("disk_read_throughput")
                write_bytes = fields.get("disk_write_throughput")
                ts = row["timestamp"]

                prev = previous_diskio.get(device)
                if prev and reads is not None and writes is not None and read_bytes is not None and write_bytes is not None:
                    dt = ts - prev["timestamp"]
                    if dt > 0:
                        read_ops = (reads - prev["reads"]) / dt
                        write_ops = (writes - prev["writes"]) / dt
                        read_throughput = (read_bytes - prev["read_bytes"]) / dt
                        write_throughput = (write_bytes - prev["write_bytes"]) / dt
                        # Avoid negative rates
                        read_ops = max(0, read_ops)
                        write_ops = max(0, write_ops)
                        read_throughput = max(0, read_throughput)
                        write_throughput = max(0, write_throughput)
                    else:
                        read_ops = write_ops = read_throughput = write_throughput = 0
                else:
                    read_ops = write_ops = read_throughput = write_throughput = 0

                if reads is not None and writes is not None and read_bytes is not None and write_bytes is not None:
                    previous_diskio[device] = {
                        "reads": reads,
                        "writes": writes,
                        "timestamp": ts,
                        "read_bytes": read_bytes,
                        "write_bytes": write_bytes,
                    }

                # Keep the maximum value seen for this timestamp
                row["disk_read_ops_per_sec"] = max(row.get("disk_read_ops_per_sec") or 0, read_ops)
                row["disk_write_ops_per_sec"] = max(row.get("disk_write_ops_per_sec") or 0, write_ops)
                row["disk_read_throughput"] = max(row.get("disk_read_throughput") or 0, read_throughput)
                row["disk_write_throughput"] = max(row.get("disk_write_throughput") or 0, write_throughput)
                print(f"DEBUG: {device} read_ops={read_ops} write_ops={write_ops} read_throughput={read_throughput} write_throughput={write_throughput}")
        elif name == "net" and tags.get("interface") == "ens3":
            net_in = fields.get("network_in_bytes")
            net_out = fields.get("network_out_bytes")
            ts = row["timestamp"]

            prev = previous_net.get("ens3")
            if prev and net_in is not None and net_out is not None:
                dt = ts - prev["timestamp"]
                if dt > 0:
                    net_in_rate = (net_in - prev["network_in_bytes"]) / dt
                    net_out_rate = (net_out - prev["network_out_bytes"]) / dt
                    net_in_rate = max(0, net_in_rate)
                    net_out_rate = max(0, net_out_rate)
                else:
                    net_in_rate = net_out_rate = 0
            else:
                net_in_rate = net_out_rate = 0

            if net_in is not None and net_out is not None:
                previous_net["ens3"] = {
                    "network_in_bytes": net_in,
                    "network_out_bytes": net_out,
                    "timestamp": ts,
                }

            row["network_in_bytes"] = net_in_rate
            row["network_out_bytes"] = net_out_rate
            row["error_count"] = fields.get("error_count")
        elif name == "ping":
            row["latency_in_ms"] = fields.get("latency_in_ms")
        elif name == "system":
            uptime = fields.get("uptime")
            if uptime:
                row["uptime_in_mins"] = uptime / 60

        # Track the latest timestamp seen
        if latest_timestamp_seen is None or ts > latest_timestamp_seen:
            latest_timestamp_seen = ts

    except Exception as e:
        print("❌ Parse error:", e)
        print("Line:", line)

def fill_missing_fields(row, required_fields):
    # Fill all fields that are None with 0
    for field in row:
        if row[field] is None:
            row[field] = 0
    return row

def flush_ready_rows_and_truncate():
    """
    Go through all timestamps in the buffer, sorted.
    If a row is complete and its timestamp is not the latest, insert it and mark as written.
    Then, rewrite the file with only unwritten timestamps.
    """
    global metrics_buffer, written_timestamps, latest_timestamp_seen

    timestamps = sorted(metrics_buffer.keys())
    for ts in timestamps:
        if ts == latest_timestamp_seen:
            continue  # Don't write the latest, wait for next batch
        row = metrics_buffer[ts]
        # Fill missing required fields with 0
        row = fill_missing_fields(row, REQUIRED_FIELDS)
        if ts not in written_timestamps:
            insert_row(row)
            written_timestamps.add(ts)
        elif ts not in written_timestamps:
            print(f"⚠️ Skipped incomplete row at {ts}")

def follow_file(path):
    print(f"🔍 Watching {path}")
    last_size = os.path.getsize(path)
    with open(path, 'r') as f:
        f.seek(0, os.SEEK_SET)
        while True:
            line = f.readline()
            if not line:
                # Check if file size has changed (new data written)
                current_size = os.path.getsize(path)
                if current_size != last_size:
                    print(f"📥 Detected new data in {path} (size changed from {last_size} to {current_size})")
                    last_size = current_size
                flush_ready_rows_and_truncate()
                time.sleep(0.5)
                continue
            print("📄 Read new line from file.")
            parse_metric_line(line)

def follow_file_snapshot(path):
    print(f"🔍 Watching {path} (snapshot mode)")
    last_size = os.path.getsize(path)
    while True:
        current_size = os.path.getsize(path)
        if current_size == 0:
            # File just got truncated, wait for refill
            time.sleep(0.2)
            continue
        if current_size != last_size:
            print(f"📥 Detected new snapshot in {path} (size changed from {last_size} to {current_size})")
            with open(path, 'r') as f:
                lines = f.readlines()
            for line in lines:
                if line.strip():
                    print("📄 Processing line from snapshot.")
                    parse_metric_line(line)
            flush_ready_rows_and_truncate()
            last_size = current_size
        time.sleep(0.2)

if __name__ == "__main__":
    follow_file_snapshot(METRICS_FILE)