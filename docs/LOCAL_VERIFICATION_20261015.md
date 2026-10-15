# Mobile verification findings - 15 October 2026

The mobile app is not fully verified or bug-free. It was built, installed and launched locally, and its actual Dart services were exercised against a local backend connected to the existing hosted database.

## Provenance and executed checks

The tested mobile checkout was commit `77909b72e8a81bcfb00a241df97423238d60c816`. Its `lib`, `android`, pubspec and lockfile match this PR's runtime files; setup documentation differs. The matching full web checkout was `58655f099bbbee320c512f3b1364f43bd2dbe239`. Flutter 3.44.1 / Dart 3.12.1 and a local backend on port 3001 were used.

- Android debug build passed using a lower-memory Gradle invocation after the initial compiler daemon crashed under host memory pressure.
- All four existing Flutter tests passed. Analysis reported no errors or warnings and 291 informational diagnostics.
- The actual mobile service audit had **seven passes and two failures**. Platform storage was mocked in this headless audit; network requests, server authorization and database access were real.
- Passed: student profile read, student exam schedule, attendance summaries, persisted student-phone update, authenticated inbox read, teacher profile/assigned courses, and teacher weekly schedule.
- Temporary student/teacher password login and session verification succeeded. Wrong-role access to administration and teacher attendance endpoints was rejected.

## Confirmed failures and incomplete features

1. **Student timetable omits valid classes.** The class-schedule provider filters course-code digits rather than the stored offering term. Two fixture slots had term 3-1; the slot whose code started 32 was omitted. The provider also derives its default section from roll and does not explicitly filter offering session; these additional concerns were reviewed in source.
2. **Manual attendance does not persist against the existing enum schema.** The actual Dart save service received HTTP 400. Direct database reproduction returned PostgreSQL `42804`: the attendance function passes text into an `attendance_status` enum column. This requires a companion database compatibility fix and enum-schema regression coverage.
3. **Missing fonts produce unhandled runtime exceptions.** Runtime font fetching is disabled, but the IBM Plex Mono assets are not bundled. Device logs explicitly reported missing Regular/Bold/SemiBold fonts. The app reached sign-in; the font errors were not established as the cause of the observed ANR.
4. **Assistant requests omit bearer authentication.** The mobile AI client does not attach the saved session token. The matching API returns 401 without it; an authenticated teacher request succeeds. Local testing also requires an endpoint pointing to the local backend.
5. **Save Marks is not connected to persistence.** The grading action only shows a success snackbar.
6. **Student results use demonstration data.** The result screen renders static sample results and a fixed sample student, not database results for the current account.
7. **Resource actions are incomplete.** Preview/download show “coming soon”; bookmarks exist only in the current widget state.

## UI/device limits and cleanup

The APK was installed and launched on Android 14/API 34 and reached sign-in. Android system and app “not responding” dialogs interrupted navigation. Host memory pressure affected the emulator; attribution of the ANR requires a healthy emulator or physical-device rerun. Full screen-by-screen acceptance, physical GPS/biometric attendance, background FCM, password recovery/change, and the complete booking/CR exam mutation lifecycle remain unverified.

Temporary student/teacher accounts and isolated academic fixture records were created only with explicit authorization, then removed. Their IDs were verified absent and original database counts restored. No real password was reset or announcement sent to real users. Credentials, private fixture data, raw logs and local machine configuration are excluded from this commit. This document reports findings; it does not implement the listed fixes.
