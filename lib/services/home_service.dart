import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/home_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeService {
  static final baseUrl = "${dotenv.env['baseUrl'] ?? ""}/api";

  Future<List<FeaturedItem>> fetchFeaturedItems() async {
    final response = await http.get(Uri.parse("$baseUrl/featured"));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => FeaturedItem.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load featured items");
    }
  }

  Future<List<PopularItem>> fetchPopularItems() async {
    final response = await http.get(Uri.parse("$baseUrl/popular"));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => PopularItem.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load popular items");
    }
  }

  Future<List<Offer>> fetchOffers() async {
    final response = await http.get(Uri.parse("$baseUrl/offers"));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Offer.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load offers");
    }
  }

  Future<List<Testimonial>> fetchTestimonials() async {
    final response = await http.get(Uri.parse("$baseUrl/testimonials"));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Testimonial.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load testimonials");
    }
  }
}
