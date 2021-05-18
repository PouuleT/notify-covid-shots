# Notify Covid Shots

> Stupid shell solution for a stupid problem

## Usage

```
pwet@w000t $ ./notify-covid-shots.sh <name_of_city> <exluded_zipcodes_regex>
```

## Example
```
pwet@w000t $ ./notify-covid-shots.sh lille "62...|59280|59500|59400|59440|59330"
```
Or if you want to loop indefinitely:
```
pwet@w000t $ while true; do ./notify-covid-shots.sh lille "62...|59280|59500|59400|59440|59330"; sleep 60; done
```
