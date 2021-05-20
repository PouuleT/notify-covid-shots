#!/bin/sh

VACCINATION_CENTERS=""
CITY="$1"
SKIP_CODES="$2"
BASE_URL="https://www.doctolib.fr"
BASE_CITY_URL="$BASE_URL/vaccination-covid-19/$CITY"
CITY_PARAMS="ref_visit_motive_ids[]=6970&ref_visit_motive_ids[]=7005&force_max_limit=2"
BASE_CENTER_URL="$BASE_URL/search_results"
CENTER_PARAMS="ref_visit_motive_ids[]=6970,7005&speciality_id=5494&search_result_format=json&force_max_limit=2"

USER_AGENT="user-agent: Mozilla/5.0 (Windows; U; Windows NT 6.1; fr; rv:1.9.0.6) Gecko/2009011913 Firefox/3.0.6"

get_vaccination_centers_by_page() {
	page="$1"
	[ -n "$page" ] && [ "$page" != 1 ] && page="&page=$page"

	curl -s "$BASE_CITY_URL?$CITY_PARAMS${page}" | grep -oP 'search-result-\K[0-9]+' | tr '\n' ' '
}

load_vaccination_centers() {
	for i in $(seq 1 4); do
		PAGE_CENTERS=$(get_vaccination_centers_by_page "$i")
		VACCINATION_CENTERS="$VACCINATION_CENTERS${PAGE_CENTERS}"
	done

	if [ -z "$VACCINATION_CENTERS" ]; then
		echo "No results for $CITY"
		exit 0
	fi
}

check_availability() {
	for center_id in $VACCINATION_CENTERS; do
		result=$(curl -H "$USER_AGENT" -s "$BASE_CENTER_URL/$center_id.json?$CENTER_PARAMS" | jq -r .)

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
