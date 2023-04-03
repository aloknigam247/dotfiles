#!/bin/bash

# Set up the list of menu items
menu_items=("Item 1" "Item 2" "Item 3" "Item 4" "Item 5")

# Set up the initial selected item index
selected_index=0

# Loop until the user selects an item
while true; do
  # Print the menu items with > pointing to the selected item
  for i in "${!menu_items[@]}"; do
    if [[ $i -eq $selected_index ]]; then
      echo "> ${menu_items[$i]}"
    else
      echo "  ${menu_items[$i]}"
    fi
  done

  # Read a single character from the user
  read -rsn1 input
  echo "input is _$input _"

  # Handle the user's input
  case $input in
    $'\x1b[A') # Up arrow key
      # Move the selected item up one index, wrapping around to the end if necessary
      ((selected_index--))
      if ((selected_index < 0)); then
        selected_index=${#menu_items[@]}-1
      fi
      ;;
    $'\x1b[B') # Down arrow key
      # Move the selected item down one index, wrapping around to the beginning if necessary
      ((selected_index++))
      if ((selected_index >= ${#menu_items[@]})); then
        selected_index=0
      fi
      ;;
    " ")
      # Toggle the selected item
      if [[ $selected_index -eq $i ]]; then
        selected_index=0
      else
        selected_index=$i
      fi
      ;;
    $'\n')
      # User has completed their selection, break out of the loop
      break
      ;;
    *)
      # Ignore any other input
      ;;
  esac
done

# Print the selected item
echo "You selected: ${menu_items[$selected_index]}"

