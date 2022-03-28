# Resources

+ File manifest: `file-manifest.json`
+ Sample attributes: `GTEx_Analysis_v8_Annotations_SampleAttributesDS.txt`
+ Selected samples: `gtex_v8.RNASEQ.Whole_Blood.samples.txt`
+ Sample object ID: `gtex_v8.RNASEQ.Whole_Blood.sample_object.txt`
+ Data client download: `dataclient_linux.zip`
+ Data client binary: `gen3-client`
+ Data client credentials: `credentials.json`

### File manifest

The file manifest can be downloaded by logging into AnVIL Gen3 Commons with your NIH
credentials and downloading the manifest through the interface. Instructions: 
[Downloading GTEx v8 Object Files](https://anvilproject.org/learn/reference/gtex-v8-free-egress-instructions#downloading-gtex-v8-object-files)

### Sample attributes 

The sample attributes are downloaded from GTEx v8:

```
wget https://storage.googleapis.com/gtex_analysis_v8/annotations/GTEx_Analysis_v8_Annotations_SampleAttributesDS.txt
```

### Selected samples

Use the `filter_samples.py` script to select samples.

Select RNA-seq samples from GTEx analysis freeze (`--query 'SMAFRZE=RNASEQ'`)
with tissue type "Whole Blood" (`--query 'SMTSD=Whole Blood'`).

```
python scripts/filter_samples.py --query 'SMAFRZE=RNASEQ' --query 'SMTSD=Whole Blood' < GTEx_Analysis_v8_Annotations_SampleAttributesDS.txt > gtex_v8.RNASEQ.Whole_Blood.samples.txt
```

### Sample object ID

This table contains the sample name and object ID needed for download.

```
tail -n+2 gtex_v8.RNASEQ.Whole_Blood.samples.txt | cut -f1 | python scripts/idquery.py > gtex_v8.RNASEQ.Whole_Blood.sample_object.txt
```

### Data client

#### Download and unzip the gen3 data client

```bash
wget https://github.com/uc-cdis/cdis-data-client/releases/download/1.0.0/dataclient_linux.zip
unzip dataclient_linux.zip
```

#### Configure gen3 data client

First need to log in to gen3 data commons using eRA commons ID.
[https://gen3.theanvil.io/identity](https://gen3.theanvil.io/identity)

Once logged in you have the opportunity to generate an API key.
The API key is saved as `credentials.json`.

Configure the gen3 client like this:

```bash
gen3-client configure --profile=bendall --cred=credentials.json --apiendpoint=https://gen3.theanvil.io
```


