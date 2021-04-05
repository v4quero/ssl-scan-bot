# ssl-scan-bot
Script written in bash to perform scans against any website and compile a graded SSL report for PCI and HIPAA compliance.
This script uses the Immuniweb.com API to generate the report for automation of SSL Scans.


The ssl-scan-bot TLS scan script will request three variables from the user, 'Domain', 'Port', and 'Company'. These variables will be used to perform the scan and generate a report for any desired company or website.

Usage for ssl-scan-bot script:

1. chmod +x ssl-scan-bot.sh
2. ./ssl-scan-bot.sh
3. Enter each variable as prompted, and press enter to commit the change.<br/>
Enter Domain to test: test.com << User entered variable<br/>
Enter Port to test: 443 << User entered variable<br/>
Enter the Company Name: Test Company << User entered variable<br/>
removing any existing report files<br/>
*<br/>
*<br/>
Beginning Immuniweb SSL Scan...<br/>
