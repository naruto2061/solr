FROM mcr.microsoft.com/windows/servercore:ltsc2019

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG SOLR_VERSION=8.6.3

ARG JAVA_BASEPATH=C:\\jdk-14
ARG JAVA_DOWNLOAD_URL=https://download.java.net/java/GA/jdk14.0.2/205943a0976c4ed48cb16f1043c5c647/12/GPL/openjdk-14.0.2_windows-x64_bin.zip
ARG JAVA_SHA256=20600c0bda9d1db9d20dbe1ab656a5f9175ffb990ef3df6af5d994673e4d8ff9

ENV JAVA_PATH=$JAVA_BASEPATH\\bin\\java.exe
ENV JAVA_HOME=$JAVA_BASEPATH

# JDK: https://jdk.java.net/archive/

RUN $newPath = ('{0}\bin;{1}' -f $env:JAVA_BASEPATH, $env:PATH); \
	Write-Host ('Updating PATH: {0}' -f $newPath); \
# Nano Server does not have "[Environment]::SetEnvironmentVariable()"
	setx /M PATH $newPath;

RUN Write-Host ('Downloading {0} ...' -f $env:JAVA_DOWNLOAD_URL); \
	#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $env:JAVA_DOWNLOAD_URL -OutFile 'openjdk.zip'; \
	Write-Host ('Verifying sha256 ({0}) ...' -f $env:JAVA_SHA256); \
	if ((Get-FileHash openjdk.zip -Algorithm sha256).Hash -ne $env:JAVA_SHA256) { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host 'Expanding ...'; \
	New-Item -ItemType Directory -Path C:\temp | Out-Null; \
	Expand-Archive openjdk.zip -DestinationPath C:\temp; \
	Move-Item -Path C:\temp\* -Destination $env:JAVA_BASEPATH; \
	Remove-Item C:\temp; \
	\
	Write-Host 'Removing ...'; \
	Remove-Item openjdk.zip -Force; \
	\
	Write-Host 'Verifying install ...'; \
	Write-Host '  javac --version'; javac --version; \
	Write-Host '  java --version'; java --version; \
	\
	Write-Host 'Complete.'

RUN Write-Host "Download solr version $env:SOLR_VERSION ..."; Invoke-WebRequest "https://archive.apache.org/dist/lucene/solr/$env:SOLR_VERSION/solr-$env:SOLR_VERSION.zip" -OutFile 'solr.zip' -UseBasicParsing ;
RUN Expand-Archive -Path solr.zip -DestinationPath 'C:/' ; ren C:\solr-$env:SOLR_VERSION C:\Solr ; Remove-Item solr.zip -Force;

USER ContainerUser
WORKDIR /

ENV PRECREATE=false
ENV PRECREATE_CORE_NAME=""
ENV PRECREATE_CONFDIR_NAME=""

COPY entry-point.ps1 ./

CMD ["powershell", "/entry-point.ps1"]
