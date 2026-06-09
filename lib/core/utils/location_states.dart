// ── US States ─────────────────────────────────────────────
const List<String> usStates = [
  'Alabama',
  'Alaska',
  'Arizona',
  'Arkansas',
  'California',
  'Colorado',
  'Connecticut',
  'Delaware',
  'Florida',
  'Georgia',
  'Hawaii',
  'Idaho',
  'Illinois',
  'Indiana',
  'Iowa',
  'Kansas',
  'Kentucky',
  'Louisiana',
  'Maine',
  'Maryland',
  'Massachusetts',
  'Michigan',
  'Minnesota',
  'Mississippi',
  'Missouri',
  'Montana',
  'Nebraska',
  'Nevada',
  'New Hampshire',
  'New Jersey',
  'New Mexico',
  'New York',
  'North Carolina',
  'North Dakota',
  'Ohio',
  'Oklahoma',
  'Oregon',
  'Pennsylvania',
  'Rhode Island',
  'South Carolina',
  'South Dakota',
  'Tennessee',
  'Texas',
  'Utah',
  'Vermont',
  'Virginia',
  'Washington',
  'West Virginia',
  'Wisconsin',
  'Wyoming',
];

// ── India States ──────────────────────────────────────────
const List<String> indiaStates = [
  'Andhra Pradesh',
  'Arunachal Pradesh',
  'Assam',
  'Bihar',
  'Chhattisgarh',
  'Goa',
  'Gujarat',
  'Haryana',
  'Himachal Pradesh',
  'Jharkhand',
  'Karnataka',
  'Kerala',
  'Madhya Pradesh',
  'Maharashtra',
  'Manipur',
  'Meghalaya',
  'Mizoram',
  'Nagaland',
  'Odisha',
  'Punjab',
  'Rajasthan',
  'Sikkim',
  'Tamil Nadu',
  'Telangana',
  'Tripura',
  'Uttar Pradesh',
  'Uttarakhand',
  'West Bengal',
  'Andaman and Nicobar Islands',
  'Chandigarh',
  'Delhi',
  'Jammu and Kashmir',
  'Ladakh',
  'Lakshadweep',
  'Puducherry',
];

// ── Get states by country ─────────────────────────────────
List<String> getStatesForCountry(String country) {
  if (country == 'India') return indiaStates;
  return usStates;
}

// ── Pincode helpers ───────────────────────────────────────
int getPinCodeLength(String country) => country == 'India' ? 6 : 5;

String getPinCodeHint(String country) =>
    country == 'India' ? '110001' : '10001';

String getPinCodeLabel(String country) =>
    country == 'India' ? 'Pin Code' : 'Zip Code';

String? validatePinCode(String value, String country) {
  final length = getPinCodeLength(country);
  if (value.isEmpty) return 'This field is required';
  if (value.length != length) {
    return '${getPinCodeLabel(country)} must be $length digits';
  }
  if (!RegExp(r'^\d+$').hasMatch(value)) {
    return 'Only numbers allowed';
  }
  return null;
}
