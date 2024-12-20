#!/bin/bash

# Simple Database Management System (DBMS) in Bash
# Author: Mohab Ashraf & Fares Kataya
# Description: A CLI-based DBMS that enables users to store and retrieve data from disk

# Create DBMS directory if it doesn't exist
mkdir -p ./DBMS 2>> ./.error.log

function mainMenu {
  echo -e "\n+---------Main Menu-------------+"
  echo "| 1. Select DB                  |"
  echo "| 2. Create DB                  |"
  echo "| 3. Rename DB                  |"
  echo "| 4. Drop DB                    |"
  echo "| 5. Show DBs                   |"
  echo "| 6. Exit                       |"
  echo "+-------------------------------+"
  echo -e "Enter Choice: \c"
  read ch
  case $ch in
    1)  selectDB ;;
    2)  createDB ;;
    3)  renameDB ;;
    4)  dropDB ;;
    5)  ls ./DBMS ; mainMenu;;
    6) exit ;;
    *) echo "Wrong Choice" ; mainMenu;
  esac
}

function selectDB {
  echo -e "Enter Database Name: \c"
  read dbName
  cd ./DBMS/$dbName 2>> ./.error.log
  if [[ $? == 0 ]]; then
    echo "Database $dbName Selected Successfully"
    tablesMenu
  else
    echo "Database Not Found"
    mainMenu
  fi
}

function createDB {
  echo -e "Enter Database Name: \c"
  read dbName
  mkdir ./DBMS/$dbName 2>> ./.error.log
  if [[ $? == 0 ]]; then
    echo "Database Created Successfully"
  else
    echo "Error Creating Database"
  fi
  mainMenu
}

function renameDB {
  echo -e "Enter Current Database Name: \c"
  read dbName
  echo -e "Enter New Database Name: \c"
  read newName
  mv ./DBMS/$dbName ./DBMS/$newName 2>> ./.error.log
  if [[ $? == 0 ]]; then
    echo "Database Renamed Successfully"
  else
    echo "Error Renaming Database"
  fi
  mainMenu
}

function dropDB {
  echo -e "Enter Database Name: \c"
  read dbName
  rm -r ./DBMS/$dbName 2>> ./.error.log
  if [[ $? == 0 ]]; then
    echo "Database Dropped Successfully"
  else
    echo "Database Not Found"
  fi
  mainMenu
}

function tablesMenu {
  echo -e "\n+--------Tables Menu------------+"
  echo "| 1. Show Tables               |"
  echo "| 2. Create Table              |"
  echo "| 3. Insert Into Table         |"
  echo "| 4. Select From Table         |"
  echo "| 5. Update Table              |"
  echo "| 6. Delete From Table         |"
  echo "| 7. Drop Table                |"
  echo "| 8. Back To Main Menu         |"
  echo "| 9. Exit                      |"
  echo "+------------------------------+"
  echo -e "Enter Choice: \c"
  read ch
  case $ch in
    1)  ls .; tablesMenu ;;
    2)  createTable ;;
    3)  insertIntoTable ;;
    4)  selectFromTable ;;
    5)  updateTable ;;
    6)  deleteFromTable ;;
    7)  dropTable ;;
    8)  cd ../.. 2>> ./.error.log; mainMenu ;;
    9)  exit ;;
    *)  echo "Wrong Choice" ; tablesMenu ;;
  esac
}

function createTable {
  echo -e "Enter Table Name: \c"
  read tableName
  if [[ -f $tableName ]]; then
    echo "Table Already Exists"
    tablesMenu
  fi
  
  echo -e "Enter Number of Columns: \c"
  read colsNum
  
  # Create table metadata file
  echo -e "Field|Type|Key" > ".$tableName"
  
  # Create table structure
  counter=1
  columns=""
  
  while [ $counter -le $colsNum ]; do
    echo -e "Enter Name of Column $counter: \c"
    read colName
    
    echo -e "Select Type of Column $colName:"
    select var in "Integer" "String"
    do
      case $var in
        "Integer" ) colType="int"; break ;;
        "String" ) colType="str"; break ;;
        * ) echo "Please select 1 or 2" ;;
      esac
    done
    
    echo -e "Is $colName a Primary Key? (y/n): \c"
    read isPK
    if [[ $isPK == "y" || $isPK == "Y" ]]; then
      colKey="PK"
    else
      colKey=""
    fi
    
    echo -e "$colName|$colType|$colKey" >> ".$tableName"
    
    columns="$columns$colName"
    if [ $counter -lt $colsNum ]; then
      columns="$columns|"
    fi
    
    ((counter++))
  done
  
  echo $columns > "$tableName"
  echo "Table Created Successfully"
  tablesMenu
}


function insertIntoTable {
  echo -e "Enter Table Name: \c"
  read tableName
  if ! [[ -f $tableName ]]; then
    echo "Table Not Found"
    tablesMenu
  fi
  
  # Get number of columns
  colsNum=$(awk 'END{print NR}' ".$tableName")
  row=""
  
  # Read data for each column
  for ((i=1; i<$colsNum; i++)); do
    colName=$(awk -F"|" -v i=$i 'NR==i+1{print $1}' ".$tableName")
    colType=$(awk -F"|" -v i=$i 'NR==i+1{print $2}' ".$tableName")
    colKey=$(awk -F"|" -v i=$i 'NR==i+1{print $3}' ".$tableName")
    
    while true; do
      echo -e "Enter $colName ($colType): \c"
      read value
      
      # Validate input type
      if [[ $colType == "int" && ! $value =~ ^[0-9]+$ ]]; then
        echo "Please enter a valid integer"
        continue
      fi
      
      # Check primary key uniqueness
      if [[ $colKey == "PK" ]]; then
        if grep -q "^$value|" "$tableName"; then
          echo "Primary key must be unique"
          continue
        fi
      fi
      
      break
    done
    
    row="$row$value"
    if [ $i -lt $((colsNum-1)) ]; then
      row="$row|"
    fi
  done
  
  echo $row >> "$tableName"
  echo "Data Inserted Successfully"
  tablesMenu
}


function selectFromTable {
  echo -e "Enter Table Name: \c"
  read tableName
  if ! [[ -f $tableName ]]; then
    echo "Table Not Found"
    tablesMenu
    return
  fi
  
  PS3="Select display option (1-4): "
  select option in "Display specific fields" "Display all fields" "Display with condition" "Back to menu"; do
    case $REPLY in
      1) # Display specific fields
         # Get and display field names from header
         IFS='|' read -r -a fields <<< $(head -n1 "$tableName")
         echo "Available fields:"
         for i in "${!fields[@]}"; do
           echo "$((i+1)). ${fields[i]}"
         done
         
         echo -e "Enter field numbers (space-separated): \c"
         read -r selections
         
         # Construct awk field selection
         awkFields=""
         for num in $selections; do
           awkFields="$awkFields\$$num\"|\"" 
         done
         awkFields=${awkFields%"\|\""} # Remove trailing delimiter
         
         awk -F'|' -v OFS='|' "{print $awkFields}" "$tableName" | column -t -s'|'
         break
         ;;
         
      2) # Display all fields
         column -t -s'|' "$tableName"
         break
         ;;
         
      3) # Display with condition
         # Show available fields
         IFS='|' read -r -a fields <<< $(head -n1 "$tableName")
         echo "Available fields:"
         for i in "${!fields[@]}"; do
           echo "$((i+1)). ${fields[i]}"
         done
         
         echo -e "Enter field number to search in: \c"
         read -r fieldNum
         
         echo -e "Enter search value: \c"
         read -r searchVal
         
         # Print header and matching rows
         awk -F'|' -v fn="$fieldNum" -v sv="$searchVal" '
           NR==1 {print; next}
           $fn ~ sv {print}
         ' "$tableName" | column -t -s'|'
         break
         ;;
         
      4) # Return to menu
         tablesMenu
         return
         ;;
         
      *) echo "Invalid option"
         ;;
    esac
  done
  
  tablesMenu
}

function updateTable {
  echo -e "Enter Table Name: \c"
  read tableName
  if ! [[ -f $tableName ]]; then
    echo "Table Not Found"
    tablesMenu
  fi
  
  echo -e "Enter Primary Key Value to Update: \c"
  read pkValue
  pkCol=$(awk -F"|" 'NR==2{print $1}' ".$tableName")
  
  # Check if primary key value exists
  rowNumber=$(awk -v pkValue="$pkValue" -F"|" '$1==pkValue {print NR}' "$tableName")
  if [[ -z $rowNumber ]]; then
    echo "Primary Key Value Not Found"
    tablesMenu
  fi
  
  # Read data for each column
  colsNum=$(awk 'END{print NR}' ".$tableName")
  updatedRow="$pkValue"  # Start with the PK value since it won't be changed
  
  for ((i=2; i<$colsNum; i++)); do
    colName=$(awk -F"|" -v i=$i 'NR==i+1{print $1}' ".$tableName")
    colType=$(awk -F"|" -v i=$i 'NR==i+1{print $2}' ".$tableName")
    
    echo -e "Enter new value for $colName (leave empty to keep current value): \c"
    read newValue
    
    if [[ -z $newValue ]]; then
      currentValue=$(awk -F"|" -v rowNumber=$rowNumber -v i=$i 'NR==rowNumber {print $i}' "$tableName")
      newValue=$currentValue
    fi
    
    # Validate input type
    if [[ $colType == "int" && ! $newValue =~ ^[0-9]+$ ]]; then
      echo "Please enter a valid integer"
      continue
    fi
    
    updatedRow="$updatedRow|$newValue"
  done
  
  # Update the row in the table
  awk -F"|" -v rowNumber=$rowNumber -v updatedRow="$updatedRow" 'NR==rowNumber {$0=updatedRow}1' "$tableName" > temp && mv temp "$tableName"
  echo "Data Updated Successfully"
  tablesMenu
}



function deleteFromTable {
  echo -e "Enter Table Name: \c"
  read tableName
  if ! [[ -f $tableName ]]; then
    echo "Table Not Found"
    tablesMenu
  fi
  
  echo -e "Enter Primary Key Value to Delete: \c"
  read pkValue
  
  if ! grep -q "^$pkValue|" "$tableName"; then
    echo "Record Not Found"
    tablesMenu
  fi
  
  sed -i "/^$pkValue|/d" "$tableName"
  echo "Record Deleted Successfully"
  tablesMenu
}

function dropTable {
  echo -e "Enter Table Name: \c"
  read tableName
  rm -f "$tableName" ".$tableName" 2>> ./.error.log
  if [[ $? == 0 ]]; then
    echo "Table Dropped Successfully"
  else
    echo "Error Dropping Table"
  fi
  tablesMenu
}

# Start the application
clear
echo "Welcome to DBMS"
echo -e "\nAUTHOR\n\tWritten by: Mohab Ashraf & Fares Kataya."
mainMenu