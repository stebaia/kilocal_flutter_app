import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/survey/data/survey_mapper.dart';
import 'package:kilocal_flutter_app/features/survey/domain/entities/pharmacy.dart';
import 'package:kilocal_flutter_app/features/survey/domain/entities/survey_answer.dart';
import 'package:kilocal_flutter_app/features/survey/domain/entities/survey_step.dart';

/// Guards the `POST /survey/submit/{internalName}` body shape confirmed by
/// backend (real fixture in `wiki/survey-domande-backend.md`).
void main() {
  SurveySection questionSection({
    required String id,
    required String questionId,
    required List<SurveyOption> options,
    bool storeInUserData = false,
    String? userDataFieldName,
    bool isDob = false,
    SurveyAnswerType type = SurveyAnswerType.radio,
    SurveyInputType inputType = SurveyInputType.text,
  }) {
    return SurveySection(
      id: id,
      sort: 0,
      conditionAction: 'show',
      useCustomCta: false,
      storeInUserData: storeInUserData,
      userDataFieldName: userDataFieldName,
      showAsDropdown: false,
      singleProductBarcodeCheck: false,
      showSingleProductCta: false,
      loadKilocalPoints: false,
      isDobQuestion: isDob,
      isGenderQuestion: false,
      isMenopausaQuestion: false,
      conditions: const [],
      question: SurveyQuestion(
        id: questionId,
        type: type,
        inputType: inputType,
        required: true,
        options: options,
      ),
    );
  }

  test('steps are keyed by question id and carry sectionId + storeToField', () {
    final gender = questionSection(
      id: '100',
      questionId: '10',
      storeInUserData: true,
      userDataFieldName: 'gender',
      options: const [
        SurveyOption(
          id: '1',
          sort: 1,
          isOther: false,
          deselectOthers: false,
          text: 'Femmina',
          valueToStore: 'f',
        ),
      ],
    );
    final free = questionSection(
      id: '101',
      questionId: '11',
      options: const [
        SurveyOption(
          id: '501',
          sort: 1,
          isOther: false,
          deselectOthers: false,
          text: 'Opt',
          valueToStore: '1',
        ),
      ],
    );
    // Info section (no question) must be skipped entirely.
    const info = SurveySection(
      id: '9',
      sort: 2,
      conditionAction: 'show',
      useCustomCta: true,
      storeInUserData: false,
      showAsDropdown: false,
      singleProductBarcodeCheck: false,
      showSingleProductCta: false,
      loadKilocalPoints: false,
      isDobQuestion: false,
      isGenderQuestion: false,
      isMenopausaQuestion: false,
      conditions: [],
    );

    final survey = Survey(
      id: '1',
      internalName: 'type_survey',
      sections: [gender, free, info],
    );

    final body = buildSubmitBody(
      answers: const [
        SurveyAnswer(
          sectionId: '100',
          storeToField: 'gender',
          selectedOptionIds: ['1'],
          optionValuesToStore: ['f'],
        ),
        SurveyAnswer(
          sectionId: '101',
          selectedOptionIds: ['501'],
          optionValuesToStore: ['1'],
        ),
        SurveyAnswer(sectionId: '9'),
      ],
      survey: survey,
    );

    final steps = body['steps'] as Map<String, dynamic>;
    // Keyed by question id (10, 11), not section id; info section skipped.
    expect(steps.keys, unorderedEquals(['10', '11']));

    expect(steps['10'], {
      'sectionId': 100,
      'storeToField': 'gender',
      'answer': {'id': 1, 'value_to_store': 'f'},
    });
    // storeToField present as null when the section does not persist data.
    expect(steps['11'], {
      'sectionId': 101,
      'storeToField': null,
      'answer': {'id': 501, 'value_to_store': '1'},
    });
  });

  test('checkbox answers are an array; is_other carries other_value', () {
    final section = questionSection(
      id: '25',
      questionId: '77',
      type: SurveyAnswerType.checkbox,
      options: const [
        SurveyOption(
          id: '44',
          sort: 1,
          isOther: false,
          deselectOthers: false,
          text: 'Diabete',
        ),
        SurveyOption(
          id: '53',
          sort: 2,
          isOther: true,
          deselectOthers: false,
          text: 'Altro',
        ),
      ],
    );
    final survey = Survey(
      id: '1',
      internalName: 'type_survey',
      sections: [section],
    );

    final body = buildSubmitBody(
      answers: const [
        SurveyAnswer(
          sectionId: '25',
          selectedOptionIds: ['44', '53'],
          otherValue: 'Ipertensione',
        ),
      ],
      survey: survey,
    );

    final step = (body['steps'] as Map)['77'] as Map<String, dynamic>;
    expect(step['answer'], [
      {'id': 44},
      {'id': 53, 'is_other': true, 'other_value': 'Ipertensione'},
    ]);
  });

  test('bmi is a float and ageValue a whole number of years', () {
    final height = questionSection(
      id: '15',
      questionId: '30',
      type: SurveyAnswerType.input,
      userDataFieldName: 'height',
      storeInUserData: true,
      options: const [],
    );
    final weight = questionSection(
      id: '16',
      questionId: '31',
      type: SurveyAnswerType.input,
      userDataFieldName: 'weight',
      storeInUserData: true,
      options: const [],
    );
    final dob = questionSection(
      id: '12',
      questionId: '28',
      type: SurveyAnswerType.input,
      inputType: SurveyInputType.date,
      isDob: true,
      userDataFieldName: 'date_of_birth',
      storeInUserData: true,
      options: const [],
    );
    final survey = Survey(
      id: '1',
      internalName: 'type_survey',
      sections: [height, weight, dob],
    );

    final body = buildSubmitBody(
      answers: const [
        SurveyAnswer(sectionId: '15', storeToField: 'height', textValue: '180'),
        SurveyAnswer(sectionId: '16', storeToField: 'weight', textValue: '75'),
        SurveyAnswer(
          sectionId: '12',
          storeToField: 'date_of_birth',
          textValue: '2000-01-01',
        ),
      ],
      survey: survey,
    );

    // 75 / 1.8^2 = 23.1
    expect(body['bmi'], 23.1);
    expect(body['bmi'], isA<double>());
    expect(body['ageValue'], isA<int>());
    expect(body['ageValue'] as int, greaterThan(0));
  });

  test('pharmacy_data carries the selected pharmacy object', () {
    final survey = Survey(
      id: '3',
      internalName: 'qr_pharmacy_1',
      sections: const [],
    );
    final body = buildSubmitBody(
      answers: const [],
      survey: survey,
      pharmacy: const Pharmacy(
        id: '171620',
        title: 'San Francesco Da Paola',
        address: 'Via San Francesco Da Paola 10',
        city: 'Torino',
        province: 'Torino',
        zip: '10123',
        region: 'Piemonte',
        storeId: '1',
      ),
    );

    expect(body['pharmacy_data'], {
      'id': 171620,
      'title': 'San Francesco Da Paola',
      'address': 'Via San Francesco Da Paola 10',
      'city': 'Torino',
      'province': 'Torino',
      'zip': '10123',
      'region': 'Piemonte',
      'store_id': '1',
    });
    expect(body['single_product_id'], isNull);
  });

  test('single_product_id derives from the dropdown option value_to_store', () {
    final dropdown = SurveySection(
      id: '78',
      sort: 0,
      conditionAction: 'show',
      useCustomCta: false,
      storeInUserData: false,
      showAsDropdown: true,
      singleProductBarcodeCheck: false,
      showSingleProductCta: false,
      loadKilocalPoints: false,
      isDobQuestion: false,
      isGenderQuestion: false,
      isMenopausaQuestion: false,
      conditions: const [],
      question: const SurveyQuestion(
        id: '90',
        type: SurveyAnswerType.radio,
        inputType: SurveyInputType.text,
        required: true,
        options: [
          SurveyOption(
            id: '148',
            sort: 1,
            isOther: false,
            deselectOthers: false,
            text: 'Kilocal AGE Menopausa',
            valueToStore: '23',
          ),
        ],
      ),
    );
    final survey = Survey(
      id: '7',
      internalName: 'single_product_survey',
      sections: [dropdown],
    );

    final body = buildSubmitBody(
      answers: const [
        SurveyAnswer(
          sectionId: '78',
          selectedOptionIds: ['148'],
          optionValuesToStore: ['23'],
        ),
      ],
      survey: survey,
    );

    expect(body['single_product_id'], 23);
    expect(body['pharmacy_data'], isNull);
  });

  test('mapPharmacy parses the pharmacies GraphQL row', () {
    final p = mapPharmacy(const {
      'id': '171620',
      'title': 'San Francesco Da Paola',
      'city': 'Torino',
      'province': 'Torino',
      'zip': '10123',
      'store_id': '1',
    });
    expect(p.id, '171620');
    expect(p.city, 'Torino');
    expect(p.toSubmitJson()['id'], 171620);
  });
}
