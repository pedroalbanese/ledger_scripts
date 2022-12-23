package main

import (
	"bufio"
	"bytes"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"time"

	"github.com/eidolon/wordwrap"
	"github.com/pedroalbanese/gofpdf"
)

var (
	admin = flag.String("a", "", "Admin password.")
	art   = flag.Bool("r", false, "Randomart.")
	enc   = flag.Bool("p", false, "Encrypt with Password.")
	in    = flag.String("f", "", "Input plaintext file.")
	l     = flag.String("l", "", "Lateral Text.")
	n     = flag.Bool("n", false, "Enumerate pages.")
	qr    = flag.String("q", "", "Insert PNG QRCode.")
	sub   = flag.String("s", "SUBTITLE", "Subtitle.")
	title = flag.String("t", "TITLE", "Title")
	user  = flag.String("u", "", "User password.")
	x     = flag.Int("x", 140, "Set x QRCode.")
	y     = flag.Int("y", 240, "Set y QRCode.")
	w     = flag.Bool("w", false, "Word wrap.")
)

func main() {
	flag.Parse()
	err := GeneratePdf("")
	if err != nil {
		panic(err)
	}
}

func GeneratePdf(filename string) error {
	pdf := gofpdf.New("P", "mm", "A4", "")

	if *enc {
		pdf.SetProtection(gofpdf.CnProtectModify, *user, *admin)
	}

	if *l != "" {
		pdf.SetHeaderFunc(func() {
			currentTime := time.Now()
			pdf.SetFont("Courier", "B", 11)
			pdf.SetTextColor(128, 128, 128)
			pdf.TransformBegin()
			pdf.TransformRotate(90, 200, 5)
			pdf.MultiCell(0, 0, *l+currentTime.Format(" Mon, 02 Jan 2006 15:04:05 -0700"), "", "", true)
			pdf.TransformEnd()
		})
	}

	pdf.AddPage()
	pdf.SetFont("Courier", "B", 25)
	pdf.MultiCell(190, 10, *title, "", "C", false)

	pdf.SetFont("Courier", "B", 18)
	pdf.SetTextColor(255, 255, 255)
	pdf.MultiCell(190, 10, *sub, "", "C", true)

	pdf.SetFont("Courier", "B", 11)

	pdf.SetTextColor(0, 0, 0)

	flag.Parse()

	if *n == true {
		pdf.SetFooterFunc(func() {
			pdf.SetY(-15)
			pdf.SetFont("Courier", "B", 12)
			pdf.SetTextColor(128, 128, 128)
			pdf.CellFormat(0, 10, fmt.Sprintf("Page %d", pdf.PageNo()),
				"", 0, "C", false, 0, "")
		})
	}

	if *w {
		var file io.Reader
		var err error
		if *in == "-" {
			file = os.Stdin
		} else {
			file, err = os.Open(*in)
			if err != nil {
				log.Fatalf("failed opening file: %s", err)
			}
		}
		scanner := bufio.NewScanner(file)
		scanner.Split(bufio.ScanLines)
		var txtlines []string

		for scanner.Scan() {
			txtlines = append(txtlines, scanner.Text())
		}
		var wrapped string
		for _, eachline := range txtlines {
			wrapper := wordwrap.Wrapper(80, true)
			wrapped = wrapper(string(eachline))

			pdf.MultiCell(300, 5, wrapped, "", "", false)
		}
	} else {
		var filerc *os.File
		var err error
		if *in == "-" {
			filerc = os.Stdin
		} else if *in != "" && *in != "-" {
			filerc, err = os.Open(*in)
			if err != nil {
				log.Fatal(err)
			}
		} else {
			flag.PrintDefaults()
			os.Exit(1)
		}

		defer filerc.Close()

		buf := new(bytes.Buffer)
		buf.ReadFrom(filerc)
		contents := buf.String()
		pdf.MultiCell(300, 5, contents, "", "", false)
	}
	return pdf.Output(os.Stdout)
}

func SplitSubN(s string, n int) []string {
	sub := ""
	subs := []string{}

	runes := bytes.Runes([]byte(s))
	l := len(runes)
	for i, r := range runes {
		sub = sub + string(r)
		if (i+1)%n == 0 {
			subs = append(subs, sub)
			sub = ""
		} else if (i + 1) == l {
			subs = append(subs, sub)
		}
	}

	return subs
}
