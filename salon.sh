#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"
# Display services
$PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id"
# Ask for service
read SERVICE_ID_SELECTED
# Check if service exists
while [[ -z $($PSQL "SELECT service_id FROM services WHERE service_id = '$SERVICE_ID_SELECTED'" 2>/dev/null) ]]
do
  echo -e "\nI could not find that service. What would you like today?"
  # Display services again
  $PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id"
  read SERVICE_ID_SELECTED
done
# Get service name
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
# Ask for customer phone
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
# Check if customer exists
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
# If customer does not exist, add customer
if [[ -z $CUSTOMER_ID ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
fi
# Ask for appointment time
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME
# Insert appointment
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')" >/dev/null
# Confirmation
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
