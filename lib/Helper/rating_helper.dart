import 'package:flutter/material.dart';
import 'package:vault/Helper/ui_constants.dart';

class RatingHelper {
  static Widget getRating(dynamic data) {
    double? metaRatingVal;
    double? userRatingVal;

    // Check for properties dynamically
    // GameModel has aggregated_rating and rating
    try {
      // ignore: avoid_dynamic_calls
      if (data.aggregated_rating != null) {
        // ignore: avoid_dynamic_calls
        metaRatingVal = (data.aggregated_rating as num).toDouble();
      }
    } catch (e) {
      // Property doesn't exist or error accessing it
    }

    try {
      // ignore: avoid_dynamic_calls
      if (data.rating != null) {
        // ignore: avoid_dynamic_calls
        userRatingVal = (data.rating as num).toDouble();
      }
    } catch (e) {
      // Property doesn't exist
    }

    // MovieModel and SerieModel have vote_average
    try {
      // ignore: avoid_dynamic_calls
      if (data.vote_average != null) {
        // If we have vote_average, treat it as userRating (0-10 -> 0-100)
        // ignore: avoid_dynamic_calls
        userRatingVal = (data.vote_average as num).toDouble() * 10;
      }
    } catch (e) {
      // Property doesn't exist
    }

    List<Widget> children = [];

    if (metaRatingVal != null) {
      children.add(_buildRatingCircle("Meta Ratings", metaRatingVal));
    }

    if (userRatingVal != null) {
      children.add(_buildRatingCircle("User Ratings", userRatingVal));
    }

    if (children.isEmpty) {
      return const SizedBox();
    }

    return Column(children: children);
  }

  static Widget _buildRatingCircle(String label, double rating) {
    int ratingInt = rating.ceil();
    double normalized = rating.clamp(0, 100) / 100.0;
    Color color = getRatingColor(rating);

    String text = "N/A";
    if (ratingInt < 20) {
      text = "Bad";
    } else if (ratingInt >= 20 && ratingInt < 50) {
      text = "Unlikely";
    } else if (ratingInt >= 50 && ratingInt < 75) {
      text = "Average";
    } else if (ratingInt >= 75 && ratingInt < 90) {
      text = "Good";
    } else if (ratingInt >= 90) {
      text = "Great";
    }

    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Stack(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(
                      value: 1,
                      color: Colors.white.withAlpha(50),
                      strokeWidth: 12,
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(
                      value: normalized,
                      color: color,
                      strokeWidth: 12,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ],
              ),
              Positioned.fill(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$ratingInt",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 25),
                      ),
                      Text(text, style: TextStyle(color: color)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Color getRatingColor(double score) {
    double normalized = score.clamp(0, 100) / 100.0;
    return Color.lerp(
        UIConstants.ratingColorStart, UIConstants.ratingColorEnd, normalized)!;
  }

  static double getScore(dynamic data) {
    try {
      // ignore: avoid_dynamic_calls
      if (data.aggregated_rating != null) {
        // ignore: avoid_dynamic_calls
        return (data.aggregated_rating as num).toDouble();
      }
    } catch (e) {
      // Property doesn't exist
    }

    try {
      // ignore: avoid_dynamic_calls
      if (data.rating != null) {
        // ignore: avoid_dynamic_calls
        return (data.rating as num).toDouble();
      }
    } catch (e) {
      // Property doesn't exist
    }

    try {
      // ignore: avoid_dynamic_calls
      if (data.vote_average != null) {
        // ignore: avoid_dynamic_calls
        return (data.vote_average as num).toDouble() * 10;
      }
    } catch (e) {
      // Property doesn't exist
    }

    return 0.0;
  }
}
