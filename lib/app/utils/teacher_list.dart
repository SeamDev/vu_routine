import 'package:string_similarity/string_similarity.dart';

Map<String, String> teacherData = {
  "Zannatul Mifta": "01738659759",
  "Faisal Aziz": "01717843998",
  "A.S.M Delwar Hossain": "01780681781",
  "Afroza Islam": "01318751114",
  "Mst. Jannatul Ferdous": "01756827725",
  "Sumaiya Tasnim Dristy": "01799011979",
  "Sraboni Mostofa": "01750859617",
};

String? findTeacher(String inputName) {
  double bestScore = 0;
  String? bestMatch;

  teacherData.forEach((key, value) {
    double score = StringSimilarity.compareTwoStrings(
      inputName.toLowerCase(),
      key.toLowerCase(),
    );

    if (score > bestScore) {
      bestScore = score;
      bestMatch = key;
    }
  });

  // 0.7 = 70%
  if (bestScore >= 0.7) {
    return teacherData[bestMatch];
  }

  return null;
}
