enum ApplicationReviewAction {
  submitted,
  underReview,
  approved,
  rejected,
  commented;

  factory ApplicationReviewAction.fromString(String value) {
    switch (value) {
      case 'submitted':
        return ApplicationReviewAction.submitted;
      case 'under_review':
        return ApplicationReviewAction.underReview;
      case 'approved':
        return ApplicationReviewAction.approved;
      case 'rejected':
        return ApplicationReviewAction.rejected;
      default:
        return ApplicationReviewAction.commented;
    }
  }
  String get description {
    switch (this) {
      case ApplicationReviewAction.submitted:
        return 'Application submitted';
      case ApplicationReviewAction.underReview:
        return 'Application moved to review';
      case ApplicationReviewAction.approved:
        return 'Application approved';
      case ApplicationReviewAction.rejected:
        return 'Application rejected';
      case ApplicationReviewAction.commented:
        return 'Admin comment added';
    }
  }

  String get label {
    switch (this) {
      case ApplicationReviewAction.submitted:
        return 'Application Submitted';
      case ApplicationReviewAction.underReview:
        return 'Under Review';
      case ApplicationReviewAction.approved:
        return 'Approved';
      case ApplicationReviewAction.rejected:
        return 'Rejected';
      case ApplicationReviewAction.commented:
        return 'Comment Added';
    }
  }
}

class ApplicationReviewLogModel {
  const ApplicationReviewLogModel({
    required this.id,
    required this.applicationId,
    required this.action,
    required this.createdAt,
    this.adminId,
    this.comment,
  });

  final String id;
  final String applicationId;
  final String? adminId;
  final ApplicationReviewAction action;
  final String? comment;
  final DateTime createdAt;

  factory ApplicationReviewLogModel.fromJson(Map<String, dynamic> json) {
    return ApplicationReviewLogModel(
      id: json['id'],
      applicationId: json['application_id'],
      adminId: json['admin_id'],
      action: ApplicationReviewAction.fromString(json['action']),
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
