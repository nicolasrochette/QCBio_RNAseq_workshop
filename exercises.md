UCLA QCBio RNAseq1 workshop — Exercises
==========

Nicolas Rochette, February 2021.

Exercise 1: UNIX warm-up
----------

### 1A: Logging in (connecting) to Hoffman-2

To log into the cluster, first open a terminal (OSX: Terminal app; Windows: Ubuntu
app, for instance), then enter the following command:

```sh
ssh my_username@hoffman2.idre.ucla.edu
# (Note: Replace `my_username` with your personal Hoffman2 user/account name.)
```

Important: Every time you connect to the Hoffman-2 cluster, you will initially
have a session on the **login node** (login server). Because this computer is
shared among all users and has limited computing resources, the first thing you
should do after logging into the cluster is to ask for an interative session on
a **worker node**, by running the command:

```sh
qrsh -l h_rt=2:00:00,h_data=8G
# This asks for a 2-hour session, allowing up to 8 GB of memory.
```

After a few seconds, you should have been given an interactive session on a
worker node. You can tell that you have moved by looking at the server name
in your command prompt: the name of the Hoffman-2 login node is `login2`,
whereas worker nodes have names like `n2190` or `n2236`.

### 1B: Obtaining the workshop data

Once you are connected to the cluster and logged into a worker node, make a copy
of the workshop data in your "home" directory:

```sh
cp -R /u/project/collaboratory/nrochett/QCBio_RNAseq1/ ~/
```

There should now be a `QCBio_RNAseq1/` directory within your home directory, with
the following contents:

```txt
QCBio_RNAseq1/
├── day1/
│   ├── Kim2016.infoTable.tsv
│   ├── P10KO_rep1.fastq.gz
│   ├── P10_rep1.fastq.gz
│   └── samples.txt
├── day2/
│   ├── Mus_musculus.GRCm38.98.chr18-19.gtf
│   └── Mus_musculus.GRCm38.dna_sm.primary_assembly.chr18-19.fa
├── day3/
│   ├── batchjob_array.bash
│   └── batchjob_single.bash
└── programs/
    ├── fastqc/
    └── trimmomatic/
```

We will use this directory throughout the workshop. The data is taken from an
RNAseq study on the developing mouse retina:

> Kim J-W, Yang H-J, Brooks MJ, et al. (2016). *NRL-Regulated Transcriptome
> Dynamics of Developing Rod Photoreceptors.* Cell Rep. 17:2460-2473.
> doi:10.1016/j.celrep.2016.10.074

The original data comprises several dozen samples, for a total of 53 gigabytes
of raw sequence data. This is too large for us to process during the workshop,
also we will mainly work with a small subset of this data:

* Only samples `P10_rep1` and `P10KO_rep1`
* Only 5% of the 37 and 45 million reads these samples normally have, or about
  1.8 and 2.2 million reads respectively.

### 1C: browsing text files

Change the directory to `QCBio_RNAseq1/day1/`. Working with the `sample.txt` and
`Kim2016.infoTable.tsv` files, try to answer the following questions:

1. How many samples does the `sample.txt` file list?
2. According to the `Kim2016.infoTable.tsv` table, what is the average read
   length?
3. How many samples are there in the KO group (NRL-/-); in the control group?

Exercise 2: FASTQ files & read quality control (QC)
----------

### 2A: Working with FASTQ files

Let's now have a look at the `P10KO_rep1.fastq.gz` file, which comprises the
sequence reads for the `P10KO_rep1` sample, in FASTQ format.

*Note: This file has been compressed with GZIP, so you may need to decompress it
using `gzip` or `zcat` to access the FASTQ text contained. Some programs (such as
the `less` text viewer, and many bioinformatic tools) know how to deal with
gzipped files.*

1. How long is the first read? Does this match the figure from the table?
2. What is the PHRED-scaled confidence for the first base call of the first read?
3. How many lines does the file have in total?
4. How many reads does this represent?

### 2B: Read QC with FastQC

FastQC is a program that parses FASTQ read files and outputs a number of
human-readable summary statistics and plots. Let's use it to check the quality
of the sequence data for our two samples, `P10KO_rep1` and `P10_rep1`. The
Hoffman-2 cluster does not provide the FastQC program, but the workshop
directory has a copy of it (in the `programs/` subdirectory).

Because we are using a personal copy of the program rather than a system-wide
installation, to run it we need to *provide the path* to the main file of the
program, for instance:

```sh
~/QCBio_RNAseq1/programs/fastqc/fastqc --help
```

*Note: `--help` (and/or `-h`) are standard options, which many programs
recognize as a request for information on how to use the program.*

Thus, we can run FastQC on the reads of the `P10KO_rep1` sample like so:

```sh
../programs/fastqc/fastqc P10KO_rep1.fastq.gz
```

1. Run FastQC on the sequence data of `P10KO` as described immedately above.
   Wait for the program to complete--this should take about a minute.
2. How many output files did FastQC create? *(Note: You can list the files in a
   directory in the order in which they were created using `ls -ltr`)*
3. When this is done (about a minute), do the same for the FASTQ file of the
   `P10_rep1` sample.

### 2C: Transfering files from/to the cluster

The easiest way to tranfer files is to use an SFTP client with a graphical
interface, such as Cyberduck.

Alternatively, files can be transfered using the command-line utilities SCP and
RSYNC. Yet larger datasets may be transfered from/to Hoffman-2 using the
grid-computing toolkit Globus.

1. Download the `P10KO_rep1_fastqc.html` and `P10_rep1_fastqc.html`  output
   files to your laptop. They are HTML file, so we can open them using a web
   browser (Safari, Edge, Chrome, Firefox...).
2. Are there obvious quality differences between the two samples?

Exercise 3: Filtering low-quality reads
----------

The first step in a sequence data analysis is usually to remove the subset of
the data that has insufficient quality -- keeping unreliable reads and base
calls can introduce unnecessary noise in the analysis.

To do so, we will use the program Trimmomatic. Like for FastQC above, the
Hoffman-2 cluster doesn't provide Trimmomatic, but there is a copy of it in
the `programs/` subdirectory of the workshop data.

*Note: The `.jar` extention in the program name indicates it is a Java
program, and should be run not directly but through the Java program, like so:*

```java -jar ~/QCBio_RNAseq1/programs/trimmomatic/trimmomatic-0.39.jar```

*Note: On Hoffman-2, to run the Java program you first need to load the Java
module, by entering the command `module load java`.*

Unlike most programs, Trimmomatic does not have much built-in documentation --
in particular, the `-h`/`--help` documentation is only minimaly useful. We can
instead refer to the Trimmomatic website
(`http://www.usadellab.org/cms/?page=trimmomatic`), which gives this example for
single-end data:

```sh
java -jar trimmomatic-0.35.jar SE -phred33 input.fq.gz output.fq.gz ILLUMINACLIP:TruSeq3-SE:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
```

1. Copy-paste the above command in a "plain text" editor (e.g. TextWrangler,
   Notepad++).

2. According to the documentation given on the Trimmomatic home page, what are
   the different parts of this command doing?

3. Modify the command so that:

* it uses the correct path to the program;
* it uses `P10KO_rep1.fastq.gz` as its input file;
* the output file is named after the `P10KO_rep1` sample, for instance
  `P10KO_rep1.trimmo.fastq.gz`;
* it uses the TrueSeq-v2 single-end adapters (c.f. the Material & Methods
  section of the original publication) -- you will need to specify the full path
  (see below) to the adapter sequences (note: alternatively, to make this more
  simple, you may justentirely delete the `ILUMINACLIP` part from the command*);
* ask for minimum leading & trailing base qualities of 20;
* ask for a minimum base quality of 20 over a 5-basepair window;
* ask for a minimum final read length of 60 basepairs (or 80% of the raw read
  length).
* at the end of the command line, add the option `-threads 1` (this is to use a
  single thread/processor, as the default is to use several)

1. Run the command, wait for completion, then make sure the output file exists
   and is not empty. (If errors occurred, fix your command and retry.)

2. Modify the command to process the other sample (`P10_rep1`); run it, and
   check the output file.

Path to TrueSeq-v2 adapter sequences:

```~/QCBio_RNAseq1/programs/trimmomatic/adapters/TruSeq2-SE.fa```

Exercise 4: Aligning reads to the reference genome
----------

Here, we will align our RNAseq Illumina reads to the reference mouse genome
using the program STAR.

### 4A: Creating a STAR genome database

Read alignment programs typically require the construction of a genome sequence
database as a preliminary step before they are able to perform read alignments.
This is necessary because aligning directly to a genome sequence in FASTA format
is not computationally efficient, but only needs to be run once.

To create a genome database against which to map reads, STAR needs the genome
sequence (FASTA file) and the gene/transcript/exon annotations (GTF file).

*Note: Because of time and memory constraints during the workshop, we will
not use the full genome, but actually only **chromosomes 18 and 19**.*

1. Hoffman-2 provides STAR as a module. Load the STAR module with the command
   `module load STAR`.
3. Within the `QCBio_RNAseq1/day2/` directory, create a `star_database/`
   subdirectory, and CD inside this directory.
4. Create a STAR database using the following commands:

```sh
fasta_file=../Mus_musculus.GRCm38.dna_sm.primary_assembly.chr18-19.fa
gtf_file=../Mus_musculus.GRCm38.98.chr18-19.gtf
STAR \
   --runMode genomeGenerate \
   --genomeFastaFiles $fasta_file \
   --sjdbGTFfile $gtf_file \
   --genomeDir ./
```

This command should take about 10 minutes to complete.

While you're waiting: what are these commands doing?

4. Once STAR has compeleted, check for errors in the terminal and in the STAR
   log file (especially toward the end), and for existing non-empty output
   files.

### 4B: Aligning reads to genome

1. To align the cleaned reads of the `P10KO_rep1` sample, we can use the following
command:

```sh
cd ~/QCBio_RNAseq1/day2/ # (Move back into the `day2` directory.)
star_db_dir=./star_database/
sample=P10KO_rep1
STAR \
    --genomeDir $star_db_dir \
    --readFilesIn ../day1/$sample.trimmo.fastq.gz \
    --readFilesCommand zcat \
    --outFileNamePrefix ./$sample. \
    --outSAMtype BAM SortedByCoordinate \
    --outFilterMismatchNmax 5 \
    --outFilterMultimapNmax 1
```

After the program completes, check for errors in the terminal and in the STAR
log file (especially toward the end), and for existing non-empty output files.

While the program runs, try to understand the above command. You can find the
description of each STAR option we have used in the help (`STAR --help`). You
can also star installing IGV on your laptop (see next exercise).

2. Review the alignment statistics in the `Log.final.out` output file. What
   proportion of reads mapped unambiguously to the genome database?

### 4C: Visualizing read alignments

It is sometimes useful to visualize read alignments directly. It should give you
a feel for the contents of BAM files, and it is also useful to gain an
more intuitive, human understanding of how the raw data behaves at a gene of
particular biological interest -- command line tools can fail to appreciate
complex patterns such as alignment artifacts, or issues related to genetic
diversity or splicing.

One popular visualization tool is the Integrated Genomics Viewer (IGV); let's
open our BAM files in IGV.

1. Install IGV on your laptop. You can download it from its homepage,
   `https://software.broadinstitute.org/software/igv/`.

2. On the cluster, using the SAMtools program, create indexes for each of your
   two read alignment (BAM) files. the `samtools index` command (you will first
   need to load the `samtools` module). This will create a BAM index (BAI) file
   for each BAM file.

3. Download your two BAM files and their two BAI files to your laptop.

4. Start IGV, and open the mouse `mm10` genome. Go to File > Load from file
   and open your two BAM files.

5. Navigate to the Pde6c gene using the search box. How do the two samples
   differ?

Exercise 5: Quantifying per-gene expression
----------

### 5A: Installing HTSeq

To quantify expression at the gene level, we will use the HTSeq program. It is
not provided by the Hoffman-2 cluster, nor in the workshop's directory. However,
you can easily install it yourself.

First, load the Python3 module with the command `module load python/3.7.2`.

You can then install HTSeq as a Python3 package:

```sh
python3 -m pip install --user HTSeq
```

This will install HTSeq at `~/.local/bin/htseq-count`.

### 5B: Tallying per-gene read counts

Use HTSeq to count the number of reads mapping to each gene. 

```sh
cd ~/QCBio_RNAseq1/day3/
sample=P10_rep1
bam_file=../day2/$sample.Aligned.sortedByCoord.out.bam
gtf_file=../day2/Mus_musculus.GRCm38.98.chr18-19.gtf
~/.local/bin/htseq-count \
    --idattr=gene_id \
    --type=exon --mode=union \
    --format=bam \
    --stranded=yes \
    $bam_file \
    $gtf_file \
    > $sample.pergene_counts
```

This should take about 1 minute. Make sure you understand what the above command
is doing; the htseq-count options are described in the HTSeq help
(available with `htseq-count --help`).

### 5C: (Optional) Merging all samples' counts into one big table

HTSeq generates a separate table of per-gene read counts for each sample. For
statistical analyses, it is more practical to merge all these tables into one
large table comprising the counts at all genes and for all samples.

There are many alternative ways to generate such a table; one such way is using
the R package edgeR.

1. On the cluster, load the R module (`module load R/3.6.1`) and start an R
   session.
2. Check whether the `edgeR` package is installed by trying to load it:
   `library('edgeR')`. If not, you need to install it by running:

```R
install.packages("BiocManager")
BiocManager::install("edgeR")
```

3. Still in R, load, merge, and save the global counts table using the
   following R commands:

```R
library(edgeR)
samples <- c('P10KO_rep1', 'P10_rep1')
files <- paste0(samples,'.Aligned.sortedByCoord.out.bam.pergene_counts')
counts <- readDGE(files, labels=samples, header=FALSE)
write.csv(counts$counts, 'counts.csv')
```
