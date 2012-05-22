#!/usr/bin/awk -f

BEGIN { FS=",";
	date = 0;
	ch1["Probe Attenuation"] = 10;
	ch2["Probe Attenuation"] = 10;
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
	printf("t,ch1,ch2\n");
    }
    else {
	printf("%g,%g,%g\n",
		    date,
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
# Remove space and control chars at the beginning and
# the end of a string
function trim(text) {
    if (match(text, "[[:graph:]].*[[:graph:]]"))
	return substr(text, RSTART, RLENGTH);

    return "";
}

