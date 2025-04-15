from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains
import time

# Set up Chrome WebDriver
driver = webdriver.Chrome()
driver.get("https://github.com/Burhanuddin-Ezzy/CIMD-Cloud-Infrastructure-Monitoring-Database/tree/main/DB%20Architecture/Tables")

# Log in to GitHub
def login_to_github(driver, username, password):
    driver.get("https://github.com/login")
    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "login_field"))).send_keys(username)
    driver.find_element(By.ID, "password").send_keys(password)
    driver.find_element(By.NAME, "commit").click()


# Rename files in the repository
def rename_files():
    x = 1  # Start with the first table
    while True:
            # Dynamically construct the XPath for the current table
            table_xpath = f"/html/body/div[1]/div[5]/div/main/turbo-frame/div/react-app/div/div/div[1]/div/div/div[1]/div/div[2]/div/div/div[4]/div/div/div/nav/ul/li[1]/ul/li[2]/ul/li[{x}]"
            
            # Click the table element
            driver.find_element(By.XPATH, table_xpath).click()
            time.sleep(1)  # Wait for the table to load

            # Iterate through files inside the table
            file_names = ["Data Retention", "Handling Large", "How It Interacts", "Performance", 
                          "Query Optimization", "Real-World", "Security", "Testing", 
                          "Thought Process", "What Queries", "Alerting", "Alternative", "READ"]
            new_file_names = ["data_retention_and_cleanup.md","handling_large_data_efficiently.md",
                                      "relation_with_other_tables.md","performance_and_scalability.md",
                                      "query_optimization.md","real_world_use_case.md","security_and_compliance.md",
                                      "testing_and_valiadation_for_data_integrity.md",
                                      "decision_making_thought_process.md","sample_queries.md","alerting_and_automation.md",
                                      "alternative_approaches.md","_readme.md"]
            y = 1
            while True:
                    # Dynamically construct the XPath for the current file
                    file_xpath = f"/html/body/div[1]/div[5]/div/main/turbo-frame/div/react-app/div/div/div[1]/div/div/div[1]/div/div[2]/div/div/div[3]/div/div/div/nav/ul/li[1]/ul/li[2]/ul/li[{x}]/ul/li[{y}]/div/div[2]/span"

                    # Click the file element
                    driver.find_element(By.XPATH, file_xpath).click()
                    time.sleep(1)  # Wait for the file to load

                    driver.find_element(By.XPATH,"/html/body/div[1]/div[5]/div/main/turbo-frame/div/react-app/div/div/div[1]/div/div/div[2]/div[2]/div/div[3]/div[2]/div/div[2]/div[1]/div[2]/div[2]/div[2]/div[2]/div[1]/span")
                    time.sleep(2)

                    file_name_field = "/html/body/div[1]/div[5]/div/main/turbo-frame/div/react-app/div/div/div[1]/div/div/div[2]/div[2]/div/div[3]/div[1]/div[1]/div/div[2]/span[2]/input"

                    file_name = driver.find_element(By.XPATH, file_name_field).get_attribute("value")

                    # Find the index of the matching entry
                    matching_index = next(i for i, entry in enumerate(file_names) if entry in file_name)
                    driver.find_element(By.XPATH, file_name_field).clear()
                    driver.find_element(By.XPATH, file_name_field).send_keys(new_file_names[matching_index])
                    time.sleep(1)
                    driver.find_element(By.XPATH, "/html/body/div[1]/div[5]/div/main/turbo-frame/div/react-app/div/div/div[1]/div/div/div[2]/div[2]/div/div[3]/div[1]/div[2]/button").click()
                    time.sleep(1)
                    driver.find_element(By.XPATH, "/html/body/div[5]/div/div/div/div[2]/div/form/div[1]/span/input").send_keys("updated file name for clean and organized look")
                    time.sleep(.5)
                    driver.find_element(By.XPATH, "/html/body/div[5]/div/div/div/div[3]/button[2]").click()
                    time.sleep(2)
                    # Add logic to rename the file or perform other actions here
                    # Increment y to move to the next file
                    y += 1

            # Increment x to move to the next table
            x += 1

# Main function
def main():
    try:
        rename_files()
    finally:
        time.sleep(5)
        driver.quit()

if __name__ == "__main__":
    main()