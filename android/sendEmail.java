void sendEmail() {

  String body = "<h1>Pokemon</h1>";
  String subject = "Gotta Catch 'Em All";

  Intent i = new Intent(Intent.ACTION_SEND);
  i.setType("text/html");
  i.putExtra(Intent.EXTRA_EMAIL, new String[]{"alexander_hjå_bitraf.no"});
  i.putExtra(Intent.EXTRA_SUBJECT, subject);
  i.putExtra(Intent.EXTRA_TEXT, Html.fromHtml(body));
  try {
    startActivity(Intent.createChooser(i, "Send email..."));
  } catch (android.content.ActivityNotFoundException ex) {
    Toast.makeText(Activity.this, getString(R.string.no_email_client), Toast.LENGTH_SHORT).show();
  }
}
