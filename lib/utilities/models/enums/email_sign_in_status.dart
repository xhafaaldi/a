enum EmailSignInStatus {
  successLoggedIn("Successfully logged you in."),
  successSignedIn("Successfully signed you in."),
  weakPassword("The password provided is too weak!"),
  emailAlreadyInUse("This email is already in use!"),
  invalidEmail("The email provided is invalid!"),
  unknownError("Unknown error!"),
  userDisabled("This user has been disabled! Please contact the developers."),
  userNotFound("This user cannot be found!"),
  wrongPassword("The password provided is invalid! Please try again.");

  final String message;
  const EmailSignInStatus(this.message);
}