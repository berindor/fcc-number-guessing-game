#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$((1 + $RANDOM % 999))
#echo "The secret number is: $SECRET_NUMBER"
echo -e "\n Enter your username:"
read USERNAME
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
if [[ -n $GAMES_PLAYED ]]
then
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
fi
echo "Guess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=1
CHECK_GUESS() {
  RE='^[0-9]+$'
  if [[ ! $1 =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read  NEW_GUESS
    ((NUMBER_OF_GUESSES++))
    CHECK_GUESS $NEW_GUESS
  elif [[ $1 == $SECRET_NUMBER ]]
  then
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    if [[ -n $GAMES_PLAYED ]]
    then
      if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
      then
        BEST_GAME=$NUMBER_OF_GUESSES
      fi
      SAVED_TO_DB=$($PSQL "UPDATE users SET best_game = $BEST_GAME, games_played = $GAMES_PLAYED + 1 WHERE username = '$USERNAME'")
    else
      SAVED_TO_DB=$($PSQL "INSERT INTO users (username, best_game, games_played) VALUES ('$USERNAME', $NUMBER_OF_GUESSES, 1)")
    fi
  elif [[ $1 -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    read  NEW_GUESS
    ((NUMBER_OF_GUESSES++))
    CHECK_GUESS $NEW_GUESS
  elif [[ $1 -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read  NEW_GUESS
    ((NUMBER_OF_GUESSES++))
    CHECK_GUESS $NEW_GUESS
  fi
}
CHECK_GUESS $GUESS