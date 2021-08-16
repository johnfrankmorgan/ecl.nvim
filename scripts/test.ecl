#workunit('name', 'ECL Testing');

restaurant := RECORD
  STRING app_no;
  STRING trading_name;
  STRING address_1;
  STRING address_2;
  STRING address_3;
  STRING town;
  STRING postcode;
  STRING country;
  STRING activities;
END;

// Syntax highlighting is case-insensitive
ds := dataset('~jfm::fel', restaurant, csv(heading(1)));

activity := RECORD
  STRING name := ds.activities;
  cnt := COUNT(GROUP);
END;

unique_activities := TABLE(ds, activity, activities);
OUTPUT(SORT(unique_activities, -cnt), NAMED('UniqueActivityCount'));

OUTPUT(COUNT(ds), NAMED('RestaurantCount'));

/**
 * Embedded C++ syntax highlighting is supported! :)
 */
BOOLEAN is_number(const string str) := beginc++
  if (!str)
    return false;

  while (*str)
    if (!isdigit(*str++))
      return false;

  return true;
endc++;

OUTPUT(ds(is_number(ds.app_no)), NAMED('RestaurantsWithNumericAppNo'));
