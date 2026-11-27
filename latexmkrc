use File::Basename qw(basename);
use File::Copy qw(copy);
use File::Path qw(make_path);

# xr reads only the companion's labels. A draft LaTeX pass writes them
# without starting a second latexmk process or replacing a finished PDF.
push @file_not_found, '^No file\s+(.+\.aux)\s*$';
add_cus_dep('tex', 'aux', 0, 'companion_labels');
sub companion_labels {
    my ($stem) = @_;
    my $doc = basename($stem);
    return 0 if $doc eq basename($root_filename);
    return 1 unless $doc eq 'main' || $doc eq 'supplementary';
    my $dir = "xr-build-$doc";
    make_path($dir);
    my $status = system('pdflatex', '-interaction=batchmode', '-halt-on-error',
                        '-draftmode', "-output-directory=$dir", "$stem.tex");
    return 1 if $status;
    return copy("$dir/$doc.aux", "$stem.aux") ? 0 : 1;
}
