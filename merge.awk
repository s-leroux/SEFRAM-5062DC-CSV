#!/usr/bin/awk -f

BEGIN { FS=",";
	date = 0.;
	ch1["Probe Attenuation"] = 10.;
	ch2["Probe Attenuation"] = 10.;
}

#
# 2-ch header
NF==5 {
    ch1[trim($1)] = $2;
    ch2[trim($3)] = $4;
}

#
# 2-ch data
NF==3 {
    if ($0 ~ /Waveform Data/) {
	checkIfCoherent();
	adjustParameters();
	
	printf("%10s %10s %10s\n", 
		    "\"t (" prefix ch1["Horizontal Units"] ")\"", 
		    "\"" ch1["Source"] " (" ch1["Vertical Units"] ")\"",
		    "\"" ch2["Source"] " (" ch2["Vertical Units"] ")\"")
    }
    else {
	printf("%10.3f %10.2f %10.2f\n",
		    date*tadjust,
		    $1/ch1["Probe Attenuation"],
		    $2/ch2["Probe Attenuation"]);
	date += ch1["Sampling Period"];
    }
}

#
# Check if the data are coherent
function checkIfCoherent() {
    if ((ch1["Memory Length"] != ch2["Memory Length"]) ||
        (ch1["Sampling Period"] != ch2["Sampling Period"]) ||
        (ch1["Vertical Units"] != ch2["Vertical Units"]) ||
	(ch1["Horizontal Units"] != ch2["Horizontal Units"])) {
	print "Inconsistent data";
	exit 99;
    }
}

#
# Adjust some parameters for a better result
function adjustParameters() {
    if (ch1["Sampling Period"] < 1e-0) { prefix = ""; tadjust = 1; }
    if (ch1["Sampling Period"] < 1e-3) { prefix = "m"; tadjust = 1e3; }
    if (ch1["Sampling Period"] < 1e-6) { prefix = "µ"; tadjust = 1e6; }
    if (ch1["Sampling Period"] < 1e-9) { prefix = "n"; tadjust = 1e9; }
}

#
# Remove space and control chars at the beginning and
# the end of a string
function trim(text) {
    if (match(text, "[[:graph:]].*[[:graph:]]"))
	return substr(text, RSTART, RLENGTH);

    return "";
}

