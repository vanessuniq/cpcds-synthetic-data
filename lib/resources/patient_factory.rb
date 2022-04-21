# frozen_string_literal: true

require 'fhir_models'
require 'date'
require_relative '../terminologies/patient'

module Patient
  # Build FHIR C4BB Patient resource instances from CPCDS
  # Initialize the class with a sythea cpcds patient in json format and US Core fhir patient
  class PatientFactory
    attr_reader :cpcds_patient, :fhir_patient

    def initialize(cpcds_patient, fhir_patient)
      @cpcds_patient = cpcds_patient
      @fhir_patient = fhir_patient
    end

    def build
      FHIR::Patient.new(
        id: @fhir_patient[:id],
        meta: meta,
        language: 'en-US',
        text: @fhir_patient[:text],
        identifier: [identifier],
        name: @fhir_patient[:name],
        telecom: @fhir_patient[:telecom],
        gender: @fhir_patient[:gender],
        birthDate: @fhir_patient[:birthDate],
        address: @fhir_patient[:address].map do |item|
          item[:district] = @cpcds_patient[:home_county]
          item
        end,
        maritalStatus: @fhir_patient[:maritalStatus],
        communication: @fhir_patient[:communication]
      )
    end

    private

    def meta
      FHIR::Meta.new(
        lastUpdated: DateTime.now.to_s,
        profile: [PATIENT_PROFILE]
      )
    end

    def identifier
      FHIR::Identifier.new(
        type: codeable_concept(PATIENT_IDENTIFIER_TYPE_SYSTEM, PATIENT_IDENTIFIER_TYPE_CODE,
                               PATIENT_IDENTIFIER_TYPE_DISPLAY, PATIENT_IDENTIFIER_TYPE_TEXT),
        system: PATIENT_IDENTIFIER_SYSTEM,
        value: cpcds_patient[:member_id]
      )
    end

    def codeable_concept(system, code, display, text)
      FHIR::CodeableConcept.new(
        coding: [coding(system, code, display)],
        text: text
      )
    end

    def coding(system, code, display)
      FHIR::Coding.new(
        system: system,
        code: code,
        display: display
      )
    end
  end
end
