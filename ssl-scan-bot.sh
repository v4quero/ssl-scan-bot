#!/bin/bash
#Set the variables
jobid="0"
jobstate="0"
#job status string for comparison against known states
jobstatus=""
#The test has started
teststarted="Test has started"
#The test is still running
testinprogress="Your test is in progress"

#variables for time and date to be added to file name
var=`date +"%FORMAT_STRING"`
now=`date +"%m_%d_%Y"`
now=`date +"%Y-%m-%d"`

#Varible for domain name and port number to be tested. The user will be prompted to enter each variable.
read -p "Enter Domain to test: " testdomain
read -p "Enter Port to test: " testport
read -p "Enter the Company Name: " company


#check for and remove any previous scan files
echo "removing any existing report files"
rm raw-report.txt >/dev/null 2>&1
rm job-info.txt >/dev/null 2>&1
echo "*"
echo "*"
#print message to user in the terminal
echo "Beginning Immuniweb SSL Scan..."
echo "*"
echo "*"
#start the SSL scan from scratch (re-scan) and output the Job ID and status to a file
{ curl -d "domain=$testdomain:443&choosen_ip=any&show_test_results=true&recheck=true" "https://www.immuniweb.com/ssl/api/v1/check/1451425590.html" > job-info.txt; } >/dev/null 2>&1
#print status message to user in terminal
echo "Setting Job ID..."
echo "*"
echo "*"
#Set the jobid variable by parsing the json output of the first command
{ jobid=$(cat job-info.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['job_id'])"); } >/dev/null 2>&1
echo "Job ID set!..."
echo "*"
echo "*"
#check the job status to see if test is complete
echo "Checking current scan job status..."

while [ $jobstate -ne 1 ]
do
	echo "Job Status: Testing still in Progress..."
	{ jobstatus=$(curl -d "job_id=$jobid" "https://www.immuniweb.com/ssl/api/v1/get_result/1451425590.html" | python3 -c "import sys, json; print(json.load(sys.stdin)['message'])"); } >/dev/null 2>&1
	if [[ "$jobstatus" == "$teststarted" ]]; then
  	  jobstate=0
	elif [[ "$jobstatus" == "$testinprogress" ]]; then
          jobstate=0
	else
    	 jobstate=1
	fi
	sleep 10
done
echo "*"
echo "*"
echo "Scan job completed..."
echo "*"
echo "*"
echo "Creating report..."
echo "*"
echo "*"
#Download the scan results using the jobid variable that was set to match the scan job ID and output the scan results to a file
{ curl -d "job_id=$jobid" "https://www.immuniweb.com/ssl/api/v1/get_result/1451425590.html" > raw-report.txt; } >/dev/null 2>&1
echo "Parsing results..."
echo "*"
echo "*"
#read the report and parse the json to pull PCI and HIPAA compliance booleans and output these to a file

#date time and  company information printed to report
echo "This scan report is generated through the Immuniweb.com API. It checks SSL/TLS security and compliance along with general security checks for the website" > weak_tls_report_${company}_${now}.txt
echo "" >> weak_tls_report_${company}_${now}.txt
echo "Date: ${now}" >> weak_tls_report_${company}_${now}.txt
echo "Company: $company" >> weak_tls_report_${company}_${now}.txt
echo"" >> weak_tls_report_${company}_${now}.txt
##highlights printed to report
echo "**Overview**" >> weak_tls_report_${company}_${now}.txt
echo "" >> weak_tls_report_${company}_${now}.txt
echo "Test Title:" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['internals']['title'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
echo "Compliance Score (all):" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['internals']['description_twitter'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
echo "PCI Compliance Score:" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['internals']['scores']['pci_dss']['description'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
echo "HIPAA Compliance Score:" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['internals']['scores']['hipaa']['description'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
echo "NIST Compliance Score" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['internals']['scores']['nist']['description'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
echo "Industry Best Practices Score:" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['internals']['scores']['industry_best_practices']['description'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt

#server information printed to report
echo "**Server Information**" >> weak_tls_report_${company}_${now}.txt
echo "" >> weak_tls_report_${company}_${now}.txt
echo "hostname:" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['server_info']['hostname']['value'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
echo "IP Address:" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['server_info']['ip']['value'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
echo "Port Number:" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['server_info']['port']['value'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
#certificate information printed to report
echo "**Certificate Information**" >> weak_tls_report_${company}_${now}.txt
echo "" >> weak_tls_report_${company}_${now}.txt
echo "Certificate issuer cn:" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['certificates']['information'][0]['issuer_cn'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
echo "cn:" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['certificates']['information'][0]['cn'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
echo "san:" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['certificates']['information'][0]['san'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
echo "Is Certificate Valid?:" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['certificates']['information'][0]['valid_now'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
echo "Does the certificate expire soon?:" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['certificates']['information'][0]['expires_soon'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
echo "Is the certificate self signed?:" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['certificates']['information'][0]['self_signed'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
echo "Is the certificate trusted?:" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['certificates']['information'][0]['trusted'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
echo "" >> weak_tls_report_${company}_${now}.txt
echo "**Invalid protocols for PCI compliance present?**" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['pci_dss']['supports_invalid_protocols']['value'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
echo "**Invalid ciphers for PCI compliance present?**" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['pci_dss']['supports_invalid_cipher_suites']['value'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
echo "**Invalid protocols for HIPAA compliance present?**" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['hipaa']['supports_invalid_protocols']['value'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "**Invalid ciphers for HIPAA compliance present?**" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['hipaa']['supports_invalid_cipher_suites']['value'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
echo "**Supports TLS 1.1?**" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['nist']['supports_tlsv1.1']['value'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
echo "**Supports TLS 1.2?**" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['nist']['supports_tlsv1.2']['value'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt
echo "**Supports TLS 1.3?**" >> weak_tls_report_${company}_${now}.txt
{ cat raw-report.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['nist']['supports_tlsv1.3']['value'])" >> weak_tls_report_${company}_${now}.txt; } >/dev/null 2>&1
echo "" >> weak_tls_report_${company}_${now}.txt

rm raw-report.txt
rm job-info.txt
echo "*******************************************"
echo "Report is complete, please see 'weak_tls_report_COMPANY_DATE.txt'"
echo "*******************************************"
