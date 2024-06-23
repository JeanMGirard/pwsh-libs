

function New-SelfSignedCertificate{
	# Create the cert
	$certname = "WSLPluginTestCert"
	$cert = New-SelfSignedCertificate -Subject "CN=$certname" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256 -Type CodeSigningCert

	# Export it to a local path
	Export-Certificate -Cert $cert -FilePath ".\$certname.cer"

	# Sign the DLL file
	Set-AuthenticodeSignature -FilePath "C:\dev\Path\To\Your\WSLPlugin.dll" -Certificate $cert
}

function Show-HelpForCertificates{
	Write-Host <<<EOF 
# import the certificate to the Trusted Root Certification Authority:
certutil -addstore "Root" ".\$certname.cer"
EOF
}