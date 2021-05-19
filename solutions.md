UCLA QCBio RNAseq1 workshop - Solutions
==========

Nicolas Rochette, February 2021.

Exercise 1
----------

### 1A

*(No correction needed.)*

### 1B

*(No correction needed.)*

### 1C

1. *How many samples does the `sample.txt` file list?*

```sh
wc -l sample.txt
```

*Note: The meaning of the `-l` option is given in the `wc` manual (`man wc`).

2. *According to the `Kim2016.infoTable.tsv` table, what is the average read
   length?*

There were a few way to answer this question, which all require to browse the
contents of this TSV table.

Importantly, TSV files are similar to CSV files, but with the columns of the
table separated by tab caracters instead of commas. Both formats are "plain
text" formats.

The quickest way was to **browse the contents of the file with the `less` text
file viewer**. Line wrapping and column width can be adjusted with the `-S` and
`-x` options respectively. The previous-to-last column of the table lists the
`AvgReadLength` of the reads for each sample, and it is 76 basepairs for all
samples except one, for which it is 85 basepairs.

```sh
less -S -x 30 Kim2016.infoTable.tsv
```

Other approaches include:

* Downloading the TSV table to your laptop and opening it with a spreadsheet
  application (e.g. Microsoft Excel) or with a plain text editor (NotePad++,
  TextWrangler...) instead of `less`.
* Noticing that the `AvgReadLength` is the 10th column and extracting this
  column with `cut -f 10`.

3. How many samples are there in the KO group (NRL-/-); in the control group?

Again, there are multiple ways to answer this question. We can for instance
count the lines that include the word `NRL-/-` with `grep`:

```sh
grep -c 'NRL-/-' Kim2016.infoTable.tsv
```

Another quick approach is to tabulate the content of the table's `Genotype`
column (the 5th column) using the `sort | uniq -c` command combination:

```sh
cut -f 5 Kim2016.infoTable.tsv | sort | uniq -c
```

```txt
    1 Genotype
    16 Nrlp-GFP
    14 Nrlp-GFP;Nrl-/-
```

There are 14 knockout samples and 16 control samples. The GFP construct (which
all samples have) is there to allows for the sorting of developping
photoreceptor cells prior to RNA extraction, which reduces the experimental
noise by removing other retinal cell types.

Exercise 2
----------

### 2A

1. How long is the first read? Does this match the figure from the table?

The first read is written on the first 4 lines of the FASTQ files, so we can
print it with:

```zcat P10KO_rep1.fastq.gz | head -n4```

We can then copy-paste the sequence and use `echo` and `wc` to count the number
of characters, taking care use echo's `-n` option to avoid adding a newline
(`\n`) character:

```echo -n "GCTGTTTAGAATTCAATGAAAATGAAGCCAAAAAAAAAAAAAAAAACTTACGGGACACAATGAAAACTTGGAGGAA" | wc```

This read is 76 basepairs long; this matches the figure from the table.

There are many other ways to get to this information, for instance with

```zcat P10KO_rep1.fastq.gz | head -n2 | tail -n1 | tr -d '\n' | wc -c```

or, with awk programming, using the `length()` function, etc.

2. What is the PHRED-scaled confidence for the first base call of the first read?

For the first base of the first read the quality character is `G`, which is
ASCII code 71, and corresponds to a quality of 38 in standard PHRED-33 encoding.

3. How many lines does the file have in total?

```gzip -cd P10KO_rep1.fastq.gz | wc -l```

The file has 8,918,036 lines.

4. How many reads does this represent?

There are four lines per reads, so 2,229,509 reads.

It is possible to get to the number of reads directly by running the FASTQ file
through the `paste - - - -` trick:

```gzip -cd P10KO_rep1.fastq.gz | paste - - - - | wc -l```

### 2B

1. Run FastQC

*(No correction needed.)*

2. How many output files did FastQC create?

FastQC creates two output files:

```txt
P10KO_rep1_fastqc.zip
P10KO_rep1_fastqc.html
```

3. Do the same for the other sample.

*(No correction needed.)*

### 2C

Refer to the recording for interpreting FastQC plots.

Exercise 3
----------

1. Copy-paste the command in a plain text editor

*(No correction needed.)*

2. What are the different parts of the command doing?

The Trimmomatic webpage give the following information:

* ILLUMINACLIP: Cut adapter and other illumina-specific sequences from the read.
* SLIDINGWINDOW: Perform a sliding window trimming, cutting once the average
  quality within the window falls below a threshold.
* LEADING: Cut bases off the start of a read, if below a threshold quality
* TRAILING: Cut bases off the end of a read, if below a threshold quality
* MINLEN: Drop the read if it is below a specified length

3. Modify the command to our needs

The updated command should be:

```sh
java -jar ~/QCBio_RNAseq1/programs/trimmomatic/trimmomatic-0.39.jar SE -phred33 -threads 1 ./P10KO_rep1.fastq.gz ./P10KO_rep1.trimmo.fastq.gz LEADING:20 TRAILING:20 SLIDINGWINDOW:5:20 MINLEN:60 ILLUMINACLIP:$HOME/QCBio_RNAseq1/programs/trimmomatic/adapters/TruSeq2-SE.fa:2:30:10
```

For convenience, this can also be written with backslashes:

```sh
java -jar ~/QCBio_RNAseq1/programs/trimmomatic/trimmomatic-0.39.jar \
    SE -phred33 -threads 1 \
    ./P10KO_rep1.fastq.gz \
    ./P10KO_rep1.trimmo.fastq.gz \
    LEADING:20 TRAILING:20 SLIDINGWINDOW:5:20 MINLEN:60 \
    ILLUMINACLIP:$HOME/QCBio_RNAseq1/programs/trimmomatic/adapters/TruSeq2-SE.fa:2:30:10
```

4. Run the command

*(No correction needed.)*

5. Process the other sample

Most simply, we can just update the name of the sample in the command.
Importantly, we must take care to edit the command in **two** places, and to
update both the input and the output file names. This introduces a risk for
human error, which could lead to mixing up the two samples and later issues
and/or a substantial loss of time as the analysis would ultimately need to be
re-done.

Alternatively, we can modify the command to use a **variable**:

```sh
sample=P10KO_rep1
java -jar ~/QCBio_RNAseq1/programs/trimmomatic/trimmomatic-0.39.jar \
    SE -phred33 \
    ./$sample.fastq.gz \
    ./$sample.trimmo.fastq.gz \
    LEADING:20 TRAILING:20 SLIDINGWINDOW:5:20 MINLEN:60 \
    ILLUMINACLIP:$HOME/QCBio_RNAseq1/programs/trimmomatic/adapters/TruSeq2-SE.fa:2:30:10
```

This also makes it straightforward to process all our samples (just two in
this case, but it could be any number) with a **for loop**:

```sh
adapters=$HOME/QCBio_RNAseq1/programs/trimmomatic/adapters/TruSeq2-SE.fa
for sample in P10KO_rep1 P10_rep1
do
    java -jar ~/QCBio_RNAseq1/programs/trimmomatic/trimmomatic-0.39.jar \
        SE -phred33 \
        ./$sample.fastq.gz \
        ./$sample.trimmo.fastq.gz \
        LEADING:20 TRAILING:20 SLIDINGWINDOW:5:20 MINLEN:60 \
        ILLUMINACLIP:$adapters:2:30:10
done
```

Exercise 4
----------

### 4A

*No correction needed.*

### 4B

1. Align reads

*No correction needed.*

2. Alignment statistics

The core statistics in the `Log.final.out` file are:

* The % of reads uniquely mapped.
* The % of reads mapped to multiple loci or to too many loci (the difference
  between the two lies in the user-provided multimapping tolerance value, i.e.
  the `--outFilterMultimapNmax` parameter). Such multilocus alignments happen
  for paralogous transcripts and transcripts that overlap repeated elements.
  For differential gene expression analyses, they can be discarded, but must be
  accounted for in analyses that attempt to quantify absolute gene expression
  levels.
* The % of reads unmapped; STAR lists reads for which no
  candidate match was found as "match too short", reads for which the match was
  not good enough as "too many mismatches", and the rest as "other.

For both samples (`P10KO_rep1` and `P10_rep1`), only about 11% of reads align
uniquely to the genome. This is a very low number -- the expectation for
typical mouse or human datasets is around 80%.

The reason for this low number is that we are not using a small fraction of the
actual real reference genome: chromosomes 18 and 19. Any read corresponding to
a gene other that those laying on these two chromosomes should not map to our
"reduced" reference genome.

Using the same commands with a complete STAR database of the mouse genome,
around 85% of reads map uniquely to the reference, and an additional 10% of
reads multi-map.

### 4C

1-4: *(No correction needed.)*

5: Sample `P10KO_rep1` evidently has many more reads overlapping the Pde6c gene
than sample `P10_rep1` does. In fact, a similar pattern is apparent across all
samples at late developmental stages: Pde6c is expressed in knock-out samples
(in which the selected cell population differentiated into cones) but it is barely
expressed in wild-type samples (in which the selected cell population
differentiated into rods).

This difference, in addition with an absence of expression at early
developmental stages, identifies Pde6c as a cone-specific gene.

Exercise 5
----------

*(No correction needed.)*
