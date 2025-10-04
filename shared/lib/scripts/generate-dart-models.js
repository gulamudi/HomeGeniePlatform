#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Simple TypeScript to Dart type mapping
const typeMapping = {
  'string': 'String',
  'number': 'double',
  'boolean': 'bool',
  'string[]': 'List<String>',
  'any': 'dynamic',
  'Date': 'DateTime',
  'UUID': 'String',
  'Timestamp': 'DateTime',
  'Phone': 'String',
  'Email': 'String',
};

// Helper function to convert TypeScript interface to Dart class
function convertToDartModel(interfaceName, properties, outputDir) {
  const className = interfaceName.replace(/Schema$/, '');
  const fileName = camelToSnake(className);

  let dartCode = `import 'package:json_annotation/json_annotation.dart';

part '${fileName}.g.dart';

@JsonSerializable()
class ${className} {
`;

  // Add properties
  const props = [];
  for (const [propName, propType] of Object.entries(properties)) {
    const dartType = mapTypeToDart(propType);
    const dartPropName = camelToSnake(propName);

    dartCode += `  @JsonKey(name: '${propName}')\n`;
    dartCode += `  final ${dartType}${propType.endsWith('?') ? '?' : ''} ${dartPropName};\n\n`;
    props.push({ name: dartPropName, type: dartType, optional: propType.endsWith('?') });
  }

  // Add constructor
  dartCode += `  const ${className}({\n`;
  props.forEach(prop => {
    dartCode += `    ${prop.optional ? '' : 'required '}this.${prop.name},\n`;
  });
  dartCode += `  });\n\n`;

  // Add fromJson and toJson
  dartCode += `  factory ${className}.fromJson(Map<String, dynamic> json) => _$${className}FromJson(json);\n`;
  dartCode += `  Map<String, dynamic> toJson() => _$${className}ToJson(this);\n`;

  dartCode += `}\n`;

  // Write to file
  const filePath = path.join(outputDir, `${fileName}.dart`);
  fs.writeFileSync(filePath, dartCode);
  console.log(`Generated: ${filePath}`);
}

function camelToSnake(str) {
  return str.replace(/([A-Z])/g, '_$1').toLowerCase().replace(/^_/, '');
}

function mapTypeToDart(tsType) {
  // Remove optional marker for mapping
  const baseType = tsType.replace('?', '');
  return typeMapping[baseType] || baseType;
}

// Parse basic type definitions from our shared types
function parseSharedTypes() {
  // This is a simplified version - in a real implementation,
  // you would parse the actual TypeScript files
  const types = {
    User: {
      id: 'String',
      email: 'String?',
      phone: 'String',
      fullName: 'String',
      avatarUrl: 'String?',
      userType: 'String',
      createdAt: 'DateTime',
      updatedAt: 'DateTime',
    },
    Address: {
      id: 'String?',
      flatHouseNo: 'String',
      buildingApartmentName: 'String?',
      streetName: 'String',
      landmark: 'String?',
      area: 'String',
      city: 'String',
      state: 'String',
      pinCode: 'String',
      type: 'String',
      isDefault: 'bool',
    },
    Service: {
      id: 'String',
      name: 'String',
      description: 'String',
      category: 'String',
      basePrice: 'double',
      durationHours: 'double',
      isActive: 'bool',
      requirements: 'List<String>',
      includes: 'List<String>',
      excludes: 'List<String>',
      imageUrl: 'String?',
      createdAt: 'DateTime',
      updatedAt: 'DateTime',
    },
    Booking: {
      id: 'String',
      customerId: 'String',
      partnerId: 'String?',
      serviceId: 'String',
      status: 'String',
      scheduledDate: 'DateTime',
      durationHours: 'double',
      address: 'dynamic', // Address object
      totalAmount: 'double',
      paymentMethod: 'String',
      paymentStatus: 'String',
      specialInstructions: 'String?',
      preferredPartnerId: 'String?',
      createdAt: 'DateTime',
      updatedAt: 'DateTime',
    },
    ApiResponse: {
      success: 'bool',
      data: 'dynamic',
      error: 'String?',
      message: 'String?',
    },
  };

  return types;
}

// Main execution
function main() {
  const outputDir = path.join(__dirname, '../../homegenie_app/lib/core/models');

  // Create output directory if it doesn't exist
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  const types = parseSharedTypes();

  // Generate Dart models
  for (const [typeName, properties] of Object.entries(types)) {
    convertToDartModel(typeName, properties, outputDir);
  }

  console.log('Dart model generation completed!');
}

main();