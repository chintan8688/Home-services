import 'dart:io';

import 'package:dio/dio.dart';
import 'package:home_services/src/utills/app_prefrences.dart';
import 'package:path/path.dart';

class UserApiProvider {
  static const BASE_URL = "https://clickaway.fanstter.com/api/";

  static Dio _dio = new Dio();

  static Future signIn(
      String email, String password, String deviceToken) async {
    try {
      Response response = await _dio.post(BASE_URL + "auth/login", data: {
        "email": email.trim(),
        "password": password.trim(),
        "device_token": deviceToken
      });
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future logoutConsumer() async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "consumer/logout",
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future logoutProfessional() async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "professional/logout",
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future sendOtp(String phone) async {
    try {
      Response response = await _dio
          .post(BASE_URL + "auth/send_otp_from_login", data: {"phone": phone});
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future signUpWithGoogle(
      String name,
      String email,
      String profilePicture,
      String socialId,
      String deviceToken,
      int roleId) async {
    try {
      Response response =
          await _dio.post(BASE_URL + "auth/google_signin", data: {
        "avatar": profilePicture,
        "name": name.trim(),
        "email": email.trim(),
        "social_id": socialId,
        "device_token": deviceToken,
        "role_id": roleId
      });
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future signUp(
    String name,
    String email,
    String phoneCode,
    String phone,
    String address,
    File profilePicture,
    int roleId,
  ) async {
    FormData formData = FormData.fromMap({
      "avatar": await MultipartFile.fromFile(profilePicture.path,
          filename: basename(profilePicture.path)),
      "name": name.trim(),
      "email": email.trim(),
      "phone_code": phoneCode.trim(),
      "phone": phone.trim(),
      "address": address.trim(),
      "role_id": roleId,
    });
    try {
      Response response =
          await _dio.post(BASE_URL + "auth/signup_consumer", data: formData);
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future verifySocialOtp(String code, String email, String phone,
      String socialId, String deviceToken) async {
    try {
      Response response =
          await _dio.post(BASE_URL + "auth/verify_social_signin_otp", data: {
        "email": email.trim(),
        "code": code,
        "phone": phone,
        "social_id": socialId,
        "device_token": deviceToken
      });
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future verifyOtp(String code, String email, String phone) async {
    try {
      Response response = await _dio.post(BASE_URL + "auth/verify_otp",
          data: {"email": email.trim(), "code": code, "phone": phone});
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future forgotPassword(String phone) async {
    try {
      Response response = await _dio
          .post(BASE_URL + "auth/forgot_password", data: {"phone": phone});
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future verifyPin(String pin, String email) async {
    try {
      Response response = await _dio.post(BASE_URL + "auth/verify_code",
          data: {"email": email.trim(), "code": pin});
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future createPassword(
      String password, String email, String deviceToken) async {
    try {
      Response response = await _dio.post(BASE_URL + "auth/create_password",
          data: {
            "email": email.trim(),
            "password": password.trim(),
            "device_token": deviceToken
          });
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future allCategories() async {
    try {
      Response response = await _dio.post(BASE_URL + "categories/all");
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future allSubCategories(int parentId) async {
    try {
      Response response = await _dio.post(
          BASE_URL + "categories/sub_categories",
          data: {"parent_id": parentId});
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future homeCategoryListConsumer() async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "home/consumer",
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future homeCategoryListProfessional() async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "home/professional",
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future postJob(
      String title,
      String description,
      double price,
      int categoryId,
      var latitude,
      var longitude,
      String address,
      var workDate,
      var workTime,
      File video,
      File audio) async {
    FormData formData = FormData.fromMap({
      "video": video != null
          ? await MultipartFile.fromFile(video.path,
              filename: basename(video.path))
          : null,
      "audio": audio != null
          ? await MultipartFile.fromFile(audio.path,
              filename: basename(audio.path))
          : null,
      "job_post": title,
      "description": description,
      "price": price,
      "category_id": categoryId,
      "latitude": latitude,
      "longitude": longitude,
      "address": address,
      "work_date": workDate,
      "work_time": workTime,
      "type": "schedule"
    });
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "job/create",
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future findProfessional(
      var latitude, var longitude, int categoryId, var distance) async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "professional/find",
          data: {
            "lat": latitude,
            "lon": longitude,
            "category_id": categoryId,
            "distance": distance
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future becomeSeller(
      String serviceTitle,
      String serviceDescription,
      int categoryId,
      String documentId,
      String address,
      var latitude,
      var longitude,
      File document,
      var skills,
      var educations,
      var languages,
      var packages,
      List previousWorkImages,
      List previousWorkVideos,
      String policeRecordId,
      File policerecordProof,
      String recordProofType,
      File billProof,
      String billProofType,
      String justiceOfPeace,
      String personOne,
      String personTwo) async {
    List photosArr = new List(previousWorkImages.length);
    for (int i = 0; i < previousWorkImages.length; i++) {
      photosArr[i] = await MultipartFile.fromFile(
        previousWorkImages[i].path,
        filename: basename(previousWorkImages[i].path),
      );
    }
    List videosArr = new List(previousWorkVideos.length);
    for (int i = 0; i < previousWorkVideos.length; i++) {
      videosArr[i] = await MultipartFile.fromFile(
        previousWorkVideos[i].path,
        filename: basename(previousWorkVideos[i].path),
      );
    }

    FormData formData = FormData.fromMap({
      "service_title": serviceTitle,
      "service_description": serviceDescription,
      "category_id": categoryId,
      "document_id": documentId,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "document": await MultipartFile.fromFile(document.path,
          filename: basename(document.path)),
      "professional_skills": skills,
      "professional_educations": educations,
      "professional_languages": languages,
      "professional_packages": packages,
      "photos": photosArr,
      "videos": videosArr.length != 0 ? videosArr : null,
      "police_record_id": policeRecordId,
      "police_record": policerecordProof != null
          ? await MultipartFile.fromFile(policerecordProof.path,
              filename: basename(policerecordProof.path))
          : null,
      "police_record_type": recordProofType,
      "bill": billProof != null
          ? await MultipartFile.fromFile(billProof.path,
              filename: basename(billProof.path))
          : null,
      "bill_type": billProofType,
      "justice_of_peace": justiceOfPeace,
      "person1": personOne,
      "person2": personTwo
    });
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "professional/become",
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future changeDuty(bool isOnDuty) async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "professional/change_duty",
          data: {"on_duty": isOnDuty},
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future jobRequest(
      String title,
      String description,
      int categoryId,
      double price,
      double latitude,
      double longitude,
      String address,
      var workDate,
      var workTime,
      int professionalId,
      int qty,
      String reqType,
      int jobId,
      int packgId) async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "job/job_request",
          data: {
            "title": title,
            "description": description,
            "price": price,
            "category_id": categoryId,
            "latitude": latitude,
            "longitude": longitude,
            "address": address,
            "work_date": workDate,
            "work_time": workTime,
            "professional_id": professionalId,
            "qty": qty,
            "type": reqType,
            "job_id": jobId,
            "package_id": packgId
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future jobRequestAcceptReject(bool isAccepted, int jobId) async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "job/accept_reject_job",
          data: {
            "is_accepted": isAccepted,
            "job_id": jobId,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future findJobs(
      double latitude, double longitude, int categoryId, var distance) async {
    try {
      Response response = await _dio.post(BASE_URL + "job/find", data: {
        "lat": latitude,
        "lon": longitude,
        "category_id": categoryId,
        "distance": distance
      });
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future consumerJobs() async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "job/consumer_jobs",
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future createBid(
      double price, int jobId, String proposalDescription) async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "job/create_bid",
          data: {
            "price": price,
            "job_id": jobId,
            "proposal_description": proposalDescription
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future bidList(int jobId) async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "job/bids_list",
          data: {
            "job_id": jobId,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future professionalServices() async {
    var token = await getUserToken();
    try {
      Response response =
          await _dio.post(BASE_URL + "professional/professional_services",
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                  'AccessToken': '$token'
                },
              ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future updateServices(var services) async {
    var token = await getUserToken();
    try {
      Response response =
          await _dio.post(BASE_URL + "professional/update_my_service",
              data: {"professional_services": services},
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                },
              ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future jobDetailForConsumer(int jobId) async {
    var token = await getUserToken();
    try {
      Response response =
          await _dio.post(BASE_URL + "job/job_details_for_consumer",
              data: {"job_id": jobId},
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                },
              ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future jobDetailForProfessional(int jobId) async {
    var token = await getUserToken();
    try {
      Response response =
          await _dio.post(BASE_URL + "job/job_details_for_professional",
              data: {"job_id": jobId},
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                },
              ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future checkinAccept(
      int jobId, int professionalId, var checkIn, String timezone) async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "job/checkin_approve",
          data: {
            "job_id": jobId,
            "professional_id": professionalId,
            "checkin": checkIn,
            "timezone": timezone
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future checkout(int jobId, var checkOut) async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "job/checkout",
          data: {
            "job_id": jobId,
            "checkout": checkOut,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future reviewToConsumer(
      int jobId, int consumerId, double rating, String comment) async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(
          BASE_URL + "job/professional_review_to_consumer",
          data: {
            "job_id": jobId,
            "comment": comment,
            "consumer_id": consumerId,
            "rating": rating
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future uploadJobProof(
      int jobId, List<File> images, List<File> videos) async {
    List photosArr = new List(images.length);
    List videosArr = new List(videos.length);
    for (int i = 0; i < images.length; i++) {
      photosArr[i] = await MultipartFile.fromFile(
        images[i].path,
        filename: basename(images[i].path),
      );
    }
    for (int i = 0; i < videos.length; i++) {
      videosArr[i] = await MultipartFile.fromFile(
        videos[i].path,
        filename: basename(videos[i].path),
      );
    }
    FormData formData = FormData.fromMap(
        {"job_id": jobId, "photos": photosArr, "videos": videosArr});
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "job/upload_proof",
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future reviewToProfessional(
      int jobId,
      int professionalId,
      String comment,
      double rating,
      double punctuality,
      double professionalism,
      double customerService,
      double completionTime,
      double satisfaction) async {
    var token = await getUserToken();
    try {
      Response response =
          await _dio.post(BASE_URL + "job/consumer_review_to_professional",
              data: {
                "job_id": jobId,
                "comment": comment,
                "professional_id": professionalId,
                "rating": rating,
                "punctuality": punctuality,
                "professionalism": professionalism,
                "customer_service": customerService,
                "completion_time": completionTime,
                "satisfaction": satisfaction,
              },
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                },
              ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future getProfessional(int professionalId) async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "professional/details",
          data: {
            "professional_id": professionalId,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future setFavourite(int professionalId) async {
    var token = await getUserToken();
    try {
      Response response =
          await _dio.post(BASE_URL + "favorite_professional/add",
              data: {
                "professional_id": professionalId,
              },
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                },
              ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future removeFavourite(int professionalId) async {
    var token = await getUserToken();
    try {
      Response response =
          await _dio.post(BASE_URL + "favorite_professional/remove",
              data: {
                "professional_id": professionalId,
              },
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                },
              ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future favouriteProfessionals() async {
    var token = await getUserToken();
    try {
      Response response =
          await _dio.post(BASE_URL + "favorite_professional/list",
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                },
              ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future checkBecomeSellerRequest() async {
    var token = await getUserToken();
    try {
      Response response =
          await _dio.post(BASE_URL + "professional/check_become_request",
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                },
              ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future professionalJobs() async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "job/professional_jobs",
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future updateProfileConsumer(String name, String address,
      String phoneCode, String phone, File profile) async {
    var token = await getUserToken();
    try {
      FormData formData = FormData.fromMap({
        "avatar": profile == null
            ? null
            : await MultipartFile.fromFile(profile.path,
                filename: basename(profile.path)),
        "name": name.trim(),
        "phone_code": phoneCode.trim(),
        "phone": phone.trim(),
        "address": address.trim(),
      });
      Response response = await _dio.post(BASE_URL + "consumer/update_profile",
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future changePasswordConsumer(String password) async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "consumer/change_password",
          data: {"password": password},
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future updateProfileProfessional(String name, String address,
      String phoneCode, String phone, File profile) async {
    var token = await getUserToken();
    try {
      FormData formData = FormData.fromMap({
        "avatar": profile == null
            ? null
            : await MultipartFile.fromFile(profile.path,
                filename: basename(profile.path)),
        "name": name.trim(),
        "phone_code": phoneCode.trim(),
        "phone": phone.trim(),
        "address": address.trim(),
      });
      Response response =
          await _dio.post(BASE_URL + "professional/update_profile",
              data: formData,
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                },
              ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future changePasswordProfessional(String password) async {
    var token = await getUserToken();
    try {
      Response response =
          await _dio.post(BASE_URL + "professional/change_password",
              data: {"password": password},
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                },
              ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future editBecomeSeller() async {
    var token = await getUserToken();
    try {
      Response response =
          await _dio.post(BASE_URL + "professional/edit_become_seller",
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                },
              ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future updateBecomeSeller(
      String serviceTitle,
      String serviceDescription,
      String documentId,
      String address,
      var latitude,
      var longitude,
      File document,
      var skills,
      var educations,
      var languages,
      var packages,
      List previousWorkImages,
      List removedImages,
      List previousWorkVideos,
      List removedVideos,
      String policeRecordId,
      File policerecordProof,
      String recordProofType,
      File billProof,
      String billProofType,
      String justiceOfPeace,
      String personOne,
      String personTwo) async {
    List photosArr = new List(previousWorkImages.length);

    for (int i = 0; i < previousWorkImages.length; i++) {
      photosArr[i] = await MultipartFile.fromFile(
        previousWorkImages[i].path,
        filename: basename(previousWorkImages[i].path),
      );
    }

    List videosArr = new List(previousWorkVideos.length);

    for (int i = 0; i < previousWorkVideos.length; i++) {
      videosArr[i] = await MultipartFile.fromFile(
        previousWorkVideos[i].path,
        filename: basename(previousWorkVideos[i].path),
      );
    }

    FormData formData = FormData.fromMap({
      "service_title": serviceTitle,
      "service_description": serviceDescription,
      "document_id": documentId,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "document": document != null
          ? await MultipartFile.fromFile(document.path,
              filename: basename(document.path))
          : null,
      "professional_skills": skills,
      "professional_educations": educations,
      "professional_languages": languages,
      "professional_packages": packages,
      "new_photos": photosArr.length != 0 ? photosArr : null,
      "remove_photos": removedImages.length != 0 ? removedImages : null,
      "new_videos": videosArr.length != 0 ? videosArr : null,
      "remove_videos": removedVideos.length != 0 ? removedVideos : null,
      "police_record_id": policeRecordId,
      "police_record": policerecordProof != null
          ? await MultipartFile.fromFile(policerecordProof.path,
              filename: basename(policerecordProof.path))
          : null,
      "police_record_type": recordProofType,
      "bill": billProof != null
          ? await MultipartFile.fromFile(billProof.path,
              filename: basename(billProof.path))
          : null,
      "bill_type": billProofType,
      "justice_of_peace": justiceOfPeace,
      "person1": personOne,
      "person2": personTwo
    });
    var token = await getUserToken();
    try {
      Response response =
          await _dio.post(BASE_URL + "professional/update_become_seller",
              data: formData,
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                },
              ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future getBankDetails() async {
    var token = await getUserToken();
    try {
      Response response =
          await _dio.post(BASE_URL + "professional/get_bank_details",
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                },
              ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future addBankDetails(id, bankType, branch, accountNumber, trn) async {
    var token = await getUserToken();
    try {
      Response response =
          await _dio.post(BASE_URL + "professional/add_update_bank",
              data: {
                "id": id,
                "bank_type": bankType,
                "branch": branch,
                "account_number": accountNumber,
                "trn": trn
              },
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                },
              ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future searchProfessional(searchQuery) async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "home/search",
          data: {
            "search": searchQuery,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future sendPushNotification(notification) async {
    String key =
        "AAAAZ3i7M1Q:APA91bHErKFcfs0upKwQtU189AAZozRaELFe5PvhfQNgz3XSLrACsI6PdMxID_xy1-glxiP9VDZIpK2TNlTG5Ys6bGQvBBPHYXufCLrIy18S75O5MxcczD5_e0c7Op_ovUxQ-o7205bL";
    try {
      Response response = await _dio.post("https://fcm.googleapis.com/fcm/send",
          data: notification,
          options: Options(headers: {
            'Authorization': 'Key=$key',
            "content-type": "application/json",
          }));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future professionalTransactions() async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(
          BASE_URL + "professional/professional_transaction_details",
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future professionalWalletBalance() async {
    var token = await getUserToken();
    try {
      Response response =
          await _dio.post(BASE_URL + "professional/professional_balance",
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                },
              ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future withdrawRequest(amount, notes) async {
    var token = await getUserToken();
    try {
      Response response =
          await _dio.post(BASE_URL + "transaction/withdraw_request",
              data: {"amount": amount, "notes": notes},
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                },
              ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future consumerTransactions() async {
    var token = await getUserToken();
    try {
      Response response =
          await _dio.post(BASE_URL + "transaction/consumer_payment",
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                },
              ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static Future disputeRequest(notes, id) async {
    var token = await getUserToken();
    try {
      Response response = await _dio.post(BASE_URL + "consumer/create_dispute",
          data: {"consumer_comment": notes, "job_id": id},
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }
}
