# frozen_string_literal: true

require_relative '../../lib/resources/patient_factory'
require_relative '../../lib/terminologies/patient'

RSpec.describe Patient::PatientFactory do
  let(:cpcds_patients) do
    fixture_path = File.join(__dir__, '..', 'fixtures', 'patients.json')
    JSON.parse(File.read(fixture_path), deep_symbolize_names: true)
  end

  let(:cpcds_patient) { cpcds_patients.first }

  let(:fhir_patient) do
    fixture_path = File.join(__dir__, '..', 'fixtures', 'fhir_patient.json')
    JSON.parse(File.read(fixture_path), symbolize_names: true) 
  end

  let(:patient_factory) do
    Patient::PatientFactory.new(cpcds_patient, fhir_patient)
  end

  let(:resource) { patient_factory.build }

  describe '#initialize' do
    it 'creates a PatientFactory instance' do
      expect(patient_factory).to be_a(described_class)
    end
  end

  describe '#build' do
    it 'creates a FHIR Patient resource' do
      expect(resource).to be_a(FHIR::Patient)
      expect(resource).to be_valid
    end
    it 'includes an id field' do
      expect(resource.id).to eq(fhir_patient[:id])
    end
    it 'includes a valid meta field' do
      expect(resource.meta).to  be_a(FHIR::Meta)
      expect(resource.meta.lastUpdated).not_to  be_empty
      expect(resource.meta.profile).to include(Patient::PATIENT_PROFILE)
    end
    it 'includes a valid text field' do
      expect(resource.text).to be_a(FHIR::Narrative)
      expect(resource.text.to_hash.transform_keys(&:to_sym)).to  eq(fhir_patient[:text])
    end
    it 'includes a valid indentifier field' do
      expect(resource.identifier).to all(be_a(FHIR::Identifier))
      expect(resource.identifier.first.type).to be_a(FHIR::CodeableConcept)
      expect(resource.identifier.first.system).to  eq(Patient::PATIENT_IDENTIFIER_SYSTEM)
      expect(resource.identifier.first.value).to eq(cpcds_patient[:member_id])
    end
    it 'includes a valid name field' do
      expect(resource.name).not_to be_empty
      expect(resource.name).to  all(be_a(FHIR::HumanName))
      expect(resource.name.map{ |elmt| elmt.to_hash.transform_keys(&:to_sym) }).to eq(fhir_patient[:name])
    end
    it 'includes a valid telecom field' do
      telecom = resource.telecom
      expect(telecom).to be_a(Array)
      if !telecom.empty?
        expect(telecom).to all(be_a(FHIR::ContactPoint))
        expect(telecom.map{ |elmt| elmt.to_hash.transform_keys(&:to_sym) }).to eq(fhir_patient[:telecom])
      end
    end
    it 'includes a valid gender field' do
      expect(resource.gender).to eq(fhir_patient[:gender])  
    end
    it 'includes a valid birthDate field' do
      expect(resource.birthDate).to eq(fhir_patient[:birthDate])
    end
    it 'includes a valid address field' do
      expect(resource.address).not_to be_empty
      expect(resource.address).to all(be_a(FHIR::Address).and have_attributes(:district => cpcds_patient[:home_county]))
      expect(resource.address).to all(be_valid)
    end
    it 'include a valid maritalStatus field' do
      expect(resource.maritalStatus).to be_a(FHIR::CodeableConcept)
      expect(resource.maritalStatus.to_hash).to eq(JSON.parse(fhir_patient[:maritalStatus].to_json))
    end
  end
end
