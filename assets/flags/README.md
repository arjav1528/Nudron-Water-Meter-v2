# Country Flag PNG Assets

This folder contains PNG flag files for all countries.

## File Naming Convention

Each flag file is named using the lowercase ISO 3166-1 alpha-2 country code followed by `.png`.

Example:
- `in.png` for India
- `us.png` for United States
- `gb.png` for United Kingdom
- `sg.png` for Singapore
- `my.png` for Malaysia

## Required Flags

The country code picker expects PNG files for all countries listed in `lib/utils/country_codes_data.dart`.

## Fallback

If a flag PNG is missing, the picker will display a placeholder with the country code letter.

