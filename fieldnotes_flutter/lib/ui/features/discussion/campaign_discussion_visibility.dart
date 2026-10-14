class CampaignDiscussionVisibility {
  static int? campaignId;
  static Object? _owner;
  static void show(Object owner, int id) {
    _owner = owner;
    campaignId = id;
  }

  static void hide(Object owner) {
    if (identical(_owner, owner)) {
      _owner = null;
      campaignId = null;
    }
  }
}
