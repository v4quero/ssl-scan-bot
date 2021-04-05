# ssl-scan-bot
Script written in bash to perform scans against any website and compile a graded SSL report for PCI and HIPAA compliance.
The ssl-scan-bot TLS scan script will request three variables from the user, 'Domain', 'Port', and 'Company'. These variables will be used to perform the scan and generate a report for any desired company or website.

Usage for ssl-scan-bot script:

chmod +x weak_tls_scan_custom.sh
./weak_tls_scan_custom.sh
Enter each variable as prompted, and press enter to commit the change.
Enter Domain to test: test.com << User entered variable
Enter Port to test: 443 << User entered variable
Enter the Company Name: Test Company << User entered variable
removing any existing report files
*
*
Beginning Immuniweb SSL Scan...
