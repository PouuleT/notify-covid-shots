# Notify Covid Shots

> Stupid shell solution for a stupid problem

Parse Doctolib website to get the list of centers around your city (you can exclude unwanted zipcodes), and send a notification with notify-send to alert you of an available vaccination slot

## Usage

```
pwet@w000t $ ./notify-covid-shots.sh
Usage: ./notify-covid-shots.sh LOWERCASE_CITY_NAME [ EXCLUDED_ZIPCODES_REGEX ]
  eg: ./notify-covid-shots.sh lille '62...|59792'
Shows availabilities of COVID19 chronodoses near your city
```

## Example
```
pwet@w000t $ ./notify-covid-shots.sh lille "62...|59280|59500|59400|59440"
Lille (59000) CHU de Lille - Centre vaccination Covid - 19:
    No availabe slots

Lille (59000) Vaccination Covid-19 - Hôpital privé de Villeneuve d'Ascq:
    No availabe slots

Lille (59000) Centre Hospitalier Universitaire de Lille (CHU):
    No availabe slots

Hautmont (59330) Centre de vaccination Covid-19 - Ville d'Hautmont:
    2021-05-19: 5 available slots
    2021-05-20: 1 available slots
```
Or if you want to loop indefinitely:
```
pwet@w000t $ while true; do ./notify-covid-shots.sh lille "62...|59280|59500|59400|59440|59330"; sleep 60; done
```
