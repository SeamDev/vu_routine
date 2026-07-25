import 'package:string_similarity/string_similarity.dart';

Map<String, String> teacherData = {
  "Shamim Ahmad": "01713140107",
  "Sabina Yasmin": "01716793242",
  "Dr. Ahammad Hossain": "01762327094",
  "Arifa Ferdousi": "01313328537",
  "Md. Mizanur Rahman": "01770702911",
  "Umme Rumman": "01716673728",
  "Mst. Jannatul Ferdous": "01756827725",
  "Sumaia Rahman": "01795381332",
  "A.S.M. Delwar Hossain": "01780681781",
  "Md. Toufikul Islam": "01701012413",
  "Md. Nour Noby": "01755774070",
  "Ayesha Akter Lima": "01701041311",
  "Salma Akter Lima": "01950427482",
  "Ipshita Tasnim Raha": "01715673436",
  "Sumaiya Tasnim": "01799011979",
  "Shamim Reza": "01921285959",
  "Akib ikbal": "01743172636",
  "Mohammad Faisal Al-Naser": "01404732567",
  "Ahmed Al Azmain": "01765388951",
  "Md. Muktar Hossain": "01776300789",
  "Tanver Ahmed": "01781949541",
  "Md. Musfiqur Rahman Mridha": "01706344983",
  "Md. Fatin Ilham": "01616425777",
  "Md. Jamil Chaudhary": "01793942198",
  "Md. Shahid Ahammed Shakil": "01766165877",
  "Zannatul Mifta": "01738659759",
  "Arun Kumar Sikder": "01741424226",
  "Sushmit Jahan Rose": "01792774195",
  "Md. Ruhul Amin": "01313529302",
  "Md. Mahfujur Rahman": "01976411722",
  "D.M. Asadujjaman": "01701042718",
  "Pallab Chowdhury": "01774895155",
  "Israt Jahan Rinky": "01710437000",
  "Protik Chakroborty": "01318988313",
  "Shorav Paul": "01834740441",
  "Arshad Wasif": "01858316636",
  "Md. Taufiq Khan": "01952749248",
  "Sumaya Hannan Shova": "01645714144",
  "Iffat Farhana": "01767529957",
  "Nafia Islam": "01733331347",
  "Susmita Paul": "01986850328",
  "Md. Fayzul Islam": "01795035574",
  "Md. Rakibul Islam": "01304172487",
  "Mst. Mazeda Noor Tasnim": "01316026819",
  "Md. Adnan Sami": "01648187304",
  "Adrita Alam": "01733331392",
  "Rokaiya Tasnim": "01747805282",
  "Shahara Laila": "01852643752",
  "Md. Farhan Tanvir Nasim": "01759116054",
  "Afroza Islam": "01318751114",
  "Humayra Tasnim": "01773303199",
  "Asim Moin Saad": "01814222664",
  "Afifa Tasneem Quanita": "01764828065",
  "Zuairia Raisa Bintay Makin": "01829051117",
  "Md. Khalid Sakib": "01722661773",
  "Md. Alamin Hossain Pappu": "01776098594",
  "Anupoma Barman Shetu": "01704680283",
  "Mohsiul Mumit Alik": "01787439759",
  "Prof. Dr. Boshir Ahmed": "01713228547",
  "Dr. Md. Johirul Islam": "01723216880",
  "Md. Faruk Hossain, Ph.D.": "01756906574",
  "Md. Faisal Rahman Badal": "1763130652",
  "Dr. Md. Mayeedul Islam": "01775093606",
  "Dr. Jewel Hossen": "01515283109",
  "Sanjoy Kumar Chakravarty": "01718076436",
  "Dr. Md. Ekramul Hamid": "01726420004",
  "Dr. Md. Iqbal Aziz Khan": "01712010916",
  "Dr. Jaker Hossain": "01919803395",
  "Dr. Md.  Ariful Islam Nahid": "01760174238",
  "Dr. Md. Golam Rashed": "01717515008",
  "Dr. Md. Hamidul Islam": "01714585201",
  "Dr. Md. Abu Bakar PK.": "01716386533",
  "Dr. Md. Sherezzaman": "01717012201",
  "Md. Sanaul Haque": "01774314119",
  "Mst. Somapti Akter": "01771180837",
  "Sanjida Sultana Rika": "01861081984",
  "Emamul Haque": "01710056688",
  "Fahamina Zahan":"01886-714826",
  "Faisal Aziz":"01717843998",
  "Subrina Ahmed Shanta":"01335899457",
  "Bebak More":"01738474122",
  "Md. Moniruzzaman Kiron":"01975589956",
  "Most. Afshara Tasnim Ritu":"01778582757",
  "Dr. MD. Ekramul Hamid":"01726420004",
  "Md. Johirul Islam":"01723216880",
  "Md. Golam Rashed":"01717515008",
  "Dr. Md. Abu Bkar PK.":"01716386533",
  "Md. Iqbal Aziz Khan":"01712010916",
  "Md. Faruk Hossain":"01756906574",
  "Dr. Md. Ariful Islam Nahid":"01760174238",
  "Dr. Md. Johurul Islam":"01731002095",
  "Dr. Md. Babul Islam":"01713098210",
  "Dr. Sinthia Shabnam Mou":"01737494524",
  "Foez Ahmed":"01718276108",
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


