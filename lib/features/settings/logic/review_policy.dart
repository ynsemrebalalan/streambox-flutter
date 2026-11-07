/// Android `ReviewHelper` esikleri.
library;

const minSuccessfulPlaybacksForReview = 5;
const minDaysBetweenReviewPrompts = 90;

bool shouldRequestReview({
  required int successfulPlaybacks,
  required int lastShownMs,
  required int nowMs,
}) {
  if (successfulPlaybacks < minSuccessfulPlaybacksForReview) return false;
  if (lastShownMs <= 0) return true;
  const minMs = minDaysBetweenReviewPrompts * 24 * 3600 * 1000;
  return nowMs - lastShownMs >= minMs;
}
