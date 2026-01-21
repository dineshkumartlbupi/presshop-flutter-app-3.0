final Map<String, int> phoneNumberMaxLengthByCountry = {
  // Format: '+CountryCode': maxDigits
  '+1': 10, // USA, Canada
  '+44': 10, // UK
  '+91': 10, // India
  '+33': 9, // France
  '+49': 11, // Germany
  '+39': 10, // Italy
  '+34': 9, // Spain
  '+81': 11, // Japan
  '+86': 11, // China
  '+61': 9, // Australia
  '+55': 11, // Brazil
  '+52': 10, // Mexico
  '+7': 10, // Russia
  '+27': 9, // South Africa
  '+82': 10, // South Korea
  '+90': 10, // Turkey
  '+234': 10, // Nigeria
  '+20': 10, // Egypt
  '+92': 10, // Pakistan
  '+880': 10, // Bangladesh
  '+62': 12, // Indonesia
  '+63': 10, // Philippines
  '+84': 10, // Vietnam
  '+66': 9, // Thailand
  // Add more countries as needed
};

final Map<String, Map<String, int>> phoneNumberLengthByCountryCode = {
  '+1': {'min': 10, 'max': 10}, // USA, Canada
  '+44': {'min': 10, 'max': 10}, // UK
  '+91': {'min': 10, 'max': 10}, // India
  '+33': {'min': 9, 'max': 9}, // France
  '+49': {'min': 10, 'max': 11}, // Germany
  '+39': {'min': 9, 'max': 10}, // Italy
  '+34': {'min': 9, 'max': 9}, // Spain
  '+81': {'min': 10, 'max': 11}, // Japan
  '+86': {'min': 11, 'max': 11}, // China
  '+61': {'min': 9, 'max': 9}, // Australia
  '+55': {'min': 10, 'max': 11}, // Brazil
  '+52': {'min': 10, 'max': 10}, // Mexico
  '+7': {'min': 10, 'max': 10}, // Russia, Kazakhstan
  '+27': {'min': 9, 'max': 9}, // South Africa
  '+82': {'min': 9, 'max': 10}, // South Korea
  '+90': {'min': 10, 'max': 10}, // Turkey
  '+234': {'min': 10, 'max': 10}, // Nigeria
  '+20': {'min': 10, 'max': 10}, // Egypt
  '+92': {'min': 10, 'max': 10}, // Pakistan
  '+880': {'min': 10, 'max': 10}, // Bangladesh
  '+62': {'min': 9, 'max': 12}, // Indonesia
  '+63': {'min': 10, 'max': 10}, // Philippines
  '+84': {'min': 9, 'max': 10}, // Vietnam
  '+66': {'min': 9, 'max': 9}, // Thailand
  // Add more if needed
};
