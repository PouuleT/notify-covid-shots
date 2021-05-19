#!/bin/sh

VACCINATION_CENTERS=""
CITY="$1"
SKIP_CODES="$2"
BASE_URL="https://www.doctolib.fr"
BASE_CITY_URL="$BASE_URL/vaccination-covid-19/$CITY"
BASE_CENTER_URL="$BASE_URL/search_results"

load_vaccination_centers() {
	VACCINATION_CENTERS="$VACCINATION_CENTERS $(curl -s "$BASE_CITY_URL?ref_visit_motive_ids[]=6970&ref_visit_motive_ids[]=7005&force_max_limit=2" | grep -oP 'search-result-\K[0-9]+')"
	for i in $(seq 2 4); do
		VACCINATION_CENTERS="$VACCINATION_CENTERS $(curl -s "$BASE_CITY_URL?ref_visit_motive_ids[]=6970&ref_visit_motive_ids[]=7005&force_max_limit=2&page=$i" | grep -oP 'search-result-\K[0-9]+')"
	done

	if [ -z "$VACCINATION_CENTERS" ]; then
		echo "No results for $CITY"
		exit 0
	fi
}

check_availability() {
	for center_id in $VACCINATION_CENTERS; do
		result=$(curl -s "$BASE_CENTER_URL/$center_id.json?ref_visit_motive_ids[]=6970,7005&speciality_id=5494&search_result_format=json&force_max_limit=2" | jq -r .)

		center_name=$(echo "$result" | jq -r .search_result.name_with_title)
		center_city=$(echo "$result" | jq -r .search_result.city)
		center_zip=$(echo "$result" | jq -r .search_result.zipcode)
		center_availabilities=$(echo "$result" | jq .availabilities[])

		echo "$center_zip" | grep -qEv "$SKIP_CODES" || continue
		echo ""
		echo "$center_city ($center_zip) $center_name:"
		if [ "$center_availabilities" = "" ]; then
			echo "    No availabe slots"
			continue
		fi

		for agenda in $(echo "$center_availabilities" | jq -c .); do
			date=$(echo "$agenda" | jq -r .date)
			slots_nb=$(echo "$agenda" | jq -r '.slots | length')
			[ "$slots_nb" = "0" ] && continue
			echo "    $date: $slots_nb available slots"
			notify-send -u critical "$center_name" "$slots_nb Available slots in $center_city the $date"
		done
	done
}

load_vaccination_centers

check_availability
