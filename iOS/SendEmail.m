-(void) sendEmail
{
    MFMailComposeViewController *emailDialog = [[MFMailComposeViewController alloc] init];
    
    if (nil == emailDialog) return ;
    else
        NSLog(@"Det kan ta litt tid å generere eposten. Vennligst vent.");
    
    NSString *imageName = @"pikachu.jpg";
    NSString *path =  [NSString stringWithFormat:@"imagePATH/%@", imageName];
    NSData *imageData = [NSData dataWithContentsOfFile:path];
    [emailDialog addAttachmentData:imageData mimeType:@"image/jpg" fileName:imageName];
    
    emailDialog.mailComposeDelegate = self;
    
    NSString *emailSubject = @"Gotta Catch 'Em All";
    
    [emailDialog setSubject:emailSubject];
    
    NSString *emailBody = @"<h1>Pokemon</h1>";
    [emailDialog setMessageBody:emailBody isHTML:YES];
    [self presentViewController:emailDialog animated:YES completion:nil];
}
