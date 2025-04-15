import csv
import random
import os

#mock data pool
first_names = [
    "John", "Jane", "Michael", "Sarah", "Emily", "James", "Jessica", "David", "Emma", "Daniel",
    "Sophia", "Liam", "Noah", "Olivia", "Benjamin", "Ava", "Lucas", "Charlotte", "Mason", "Amelia"
]

last_names = [
    "Doe", "Smith", "Brown", "Johnson", "Davis", "Wilson", "Taylor", "Anderson", "Thomas", "Moore",
    "Martin", "White", "Clark", "Hall", "Allen", "Scott", "Wright", "King", "Hill", "Green"
]

cities = [
    "New York", "Los Angeles", "Chicago", "Houston", "San Francisco", "Seattle", "Miami", "Austin", "Boston", "Denver",
    "Phoenix", "Philadelphia", "Dallas", "San Diego", "San Jose", "Orlando", "Atlanta", "Detroit", "Portland",
    "Las Vegas"
]
#define the file location before opening it

folder_path = "C:/Users/burha/Desktop/Python Files"  #absolute path
file_name = "database_mock_data.csv"

if not os.path.exists(folder_path):
    os.makedirs(folder_path)

file_path = os.path.join(folder_path, file_name)
print (file_path)


#open csv file

with open(file_name, "w", newline="") as ezzy:
    writer = csv.writer(ezzy)
    writer.writerow(["id", "first_name", "last_name", "email", "age", "city"])  #Header Row

    for i in range(1, 101):
        first_name = random.choice(first_names)
        last_name = random.choice(last_names)
        email = f"{first_name.lower()}.{last_name.lower()}@mockmail.com"
        age = random.randint(16, 81)
        city = random.choice(cities)
        writer.writerow([i, first_name, last_name, email, age, city])

print("Mock data file 'database_mock_data.csv' created successfully, Burhanuddin!")
print("Current Working Directory:", os.getcwd())
