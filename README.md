# RISE Rheinschifffahrt Showcase

Sample data set exemplifying an idealized data processing pipeline:

![alt text](https://github.com/RISE-UNIBAS/rheinschifffahrt/blob/master/docs/pipeline.png?raw=true)

[![DOI](https://zenodo.org/badge/465364947.svg)](https://zenodo.org/badge/latestdoi/465364947)

## Creator

This dataset was created by the University of Basel's Research and Infrastructure Support RISE (rise@unibas.ch) in 2022. It is based on the digital collection "Basler Rheinschifffahrt-Aktiengesellschaft, insbesondere über die Veräusserung des Dieselmotorbootes 'Rheinfelden' und die Gewährung eines Darlehens zur Finanzierung der Erstellung des Dieselmotorbootes 'Rhyblitz' an diese Firma" (shelf mark: `CH SWA HS 191 V 10`, persistent link: http://dx.doi.org/10.7891/e-manuscripta-54917, referred to as "the collection" in what follows) of the Schweizer Wirtschaftsarchiv.

## File structure and data overview

Note that there are [different versions of this dataset](https://github.com/RISE-UNIBAS/rheinschifffahrt/releases).

Data in [/files](https://github.com/RISE-UNIBAS/rheinschifffahrt/tree/master/files) with
- analysis of images and transcriptions in [/files/analysis](https://github.com/RISE-UNIBAS/rheinschifffahrt/master/files/analysis)
- images in [/files/images](https://github.com/RISE-UNIBAS/rheinschifffahrt/tree/master/files/images)
- metadata in [/files/metadata](https://github.com/RISE-UNIBAS/rheinschifffahrt/tree/master/files/metadata)
- transcriptions (and corresponding metadata) in [/files/transcriptions](https://github.com/RISE-UNIBAS/rheinschifffahrt/tree/master/files/transcriptions)
- metadata schemas in [/files/schemas](https://github.com/RISE-UNIBAS/rheinschifffahrt/tree/master/files/schemas)

## Description of the collection

Todo.

## Data processing

The main task of data processing was to structure and transcribe the collection.

- Images were extracted from the collection by importing the collection into Transkribus (Expert Client v.1.17.0) and then exporting its 137 images as JPEGs `/files/images`. The sequence of the images by name (`0001.jpg` to `0137.jpg`) is the sequence of the images in the collection; note that image `0001.jpg` is a cover page (this metadata on the collection in Transkribus is provided by `transkribus_metadata.xml` and `transkribus_mets.xml`). 
- Images in the `/files/images` were then grouped into semantic items using Tropy (v1.11.1) following the inscribed item numbers provided by the collection: a red penciled number in the right upper corner of an image indicates a new item. There are 68 such items consisting of 1 to 8 images. All items are letters (with enclosures where appropriate) except for items number 30 and 44 (journal articles), item 54 (transcript of phone call), and item 56 (telegraph). Each non-exceptional item was assigned metadata using the "Tropy Correspondence" template (see https://docs.tropy.org/before-you-begin/metadata#tropy-correspondence). Two transcriptions rules were employed: 1. `purl.org/dc/elements/1.1/title` is interpreted as document inscribed number and written as "Dokument nn" where 0 ≤ n ≤ 9, and 2. `purl.org/dc/elements/1.1/creator` and `purl.org/dc/terms/audience` were interpreted as sender and receiver respectively and transcribed diplomatically (i.e., exactly as seen is without normalization, with descending order of priority: letterhead and address; salutation and signature; letter body); inferred sender or receiver metadata is indicated with square brackets. The so generated metadata is available in `files/metadata/tropy_diplomatic_metadata.json`.
- Each image in `/files/images` was automatically segmented with CITlab Advanced and transcribed with PyLaia Transkribus print 0.3 using Transkribus (Expert Client v.1.17.0). Neither segmentation nor transcription was manually corrected. The transcriptions were exported to the `/files/transcriptions` which contains transcriptions in four different formats: ALTO XML in `/files/transcriptions/alto`, PAGE XML in the folder `/files/transcriptions/page`, TEI XML in the folder `/files/transcriptions/tei`, and plain text in folder `/files/transcriptions/txt`. The folders `/files/transcriptions/alto`, `/files/transcriptions/page` and `/files/transcriptions/txt` contain a transcription for each image in `/files/images` (e.g., `0002.xml` in `files/transcriptions/alto` is the transcription of `0002.jpg` in `/files/images`; see the `/images/transkribus_metadata.xml` for the full details). In addition, `/files/transcriptions/page`, `/files/transcriptions/tei` and `/files/transcriptions/txt` contain the files `full_transcription.xml` and `full_transcription.txt` respectively with full transcriptions of all the images in `files/images`.

## Data analysis

The main task of data analysis was to automatically extract the persons mentioned in the collection using NER.

### NER using R and OpenRefine 

- The first step was to read each TXT-file into RStudio using R (v.4.1.1) to process the text and to have a basic identifier that can link any named entities back to the page they appeared on. This was done by listing all TXT-files and then reading them using the `readtext()` function (see https://cran.r-project.org/web/packages/readtext/readtext.pdf). The `doc-id` variable copies the file-name (e.g., `0001.txt`) and since this mirrors the image names (e.g., `0001.jpg`), the `doc-id` was used as a basis to create a variable `image` which links back to the relevant JPG-file. Next the spacyr (see https://github.com/quanteda/spacyr) `de_core_news_sm` model is used to parse all the texts and perform a named entity recognition. Every entity tagged as `PER`, named persons, will be used for further processing in OpenRefine. Since the linking variable unfortunately disappers when the text is parsed and a new document identifier is created (`text1`, `text2`, etc.), the original link (`0001.jpg`) was recreated using an `ifelse()`-chain. The resulting data frame was saved as `analysis/ner/persons.csv`, with the column `link` providing the name of the respective JPG-file. The script `files/spacy_update.R` documents all these processes.
- In OpenRefine, a text facet was added to `entity_type` to only include entities labelled `PER`. On the basis of the column named `entity`, a new column called `no.title` was created where titles were dropped (namely "Dr." and "Herrn"). Clustering was not an option for this new column, so it was further edited by hand: different spellings of the same name were normalized and entities that were labelled as `PER` but did not refer to a person were dropped. The resulting data frame (now only consisting of entities labelled `PER`) was then saved as `files/analysis/ner/persons_openrefine.csv`. All the changes made in OpenRefine are documented in `files/analysis/ner/persons_openrefine_changelog.json`.

### NER using Python and Protegé

- The `App.entities_per_document` method documented in `files/analysis/ner.py` was run to extract named entities per item using the spaCy (see https://spacy.io/)`de_core_news_lg` model and saved as `/files/analaysis/ner_python/ner_per_item.csv`.
- The extracted `PER` labels were manually controlled (i.e., non-persons labeled `PER` were deleted) and saved as `/files/analaysis/ner_python/ner_per_item_controlled.csv`.
- A minimal ontology for name normalization based on the "GND Ontology" (see https://d-nb.info/standards/elementset/gnd) was created using Protegé (v.5.5.0) and exported to `/files/analysis/schmeas/pnd.owl`. The names in `/files/analaysis/ner_python/ner_per_item_controlled.csv` were then manually normalized and the result saved as `/files/analaysis/ner_python/ner_per_item_normalized.csv`. Note that `dc:source`, `spacy:ent.start_char`, and `spacy:ent.end_char` jointly constitute `pnd:source`, and that `spacy:ent.text` is equivalent to `pnd:hasText` in this context.
- Finally, the names normalized in `/files/analaysis/ner_python/ner_per_item_normalized.csv` were manually aggregated into persons and saved as `/files/analaysis/ner_python/ner_individualized.json`.

## Data presentation
 - Some created data is presented at the University of Bern's Omeka S instance: https://omeka.unibe.ch/s/rheinschifffahrt

## License

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.

