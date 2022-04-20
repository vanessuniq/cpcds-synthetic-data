# frozen_string_literal: true

module Patient
  PATIENT_PROFILE = 'http://hl7.org/fhir/us/carin-bb/StructureDefinition/C4BB-Patient'
  PATIENT_IDENTIFIER_TYPE_SYSTEM = 'http://terminology.hl7.org/CodeSystem/v2-0203'
  PATIENT_IDENTIFIER_TYPE_CODE = 'MB'
  PATIENT_IDENTIFIER_TYPE_DISPLAY = 'Member Number'
  PATIENT_IDENTIFIER_TYPE_TEXT = 'An identifier for the insured of an insurance policy (this insured always has a subscriber), usually assigned by the insurance carrier.'
  PATIENT_IDENTIFIER_SYSTEM = 'https://github.com/synthetichealth/synthea'
end
