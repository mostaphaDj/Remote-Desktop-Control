// 720 ЭЪь гиб
{*******************************************************}
{                                                       }
{       CodeGear Delphi Runtime Library                 }
{       JPEG Image Compression/Decompression Unit       }
{                                                       }
{  	    Copyright (c) 1995-2008 CodeGear	        }
{                                                       }
{*******************************************************}
{$HPPEMIT '#pragma link "jpeg.obj"'}

unit jpeg;

interface

uses 
  Windows, SysUtils, Classes, Graphics;

type
  TJPEGQualityRange = 1..100;   // 100 = best quality, 25 = pretty awful
  TJPEGScale = (jsFullSize, jsHalf, jsQuarter, jsEighth);

  TJPEGImage = class(TObject)
  private
    FImage: TCustomMemoryStream;
    FBitmap: TBitmap;
    FGrayScale: Boolean;
    FQuality: TJPEGQualityRange;
    FProgressiveEncoding: Boolean;
    FScale: TJPEGScale;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Compress;InLine;
    procedure Decompress;InLine;

    // Options affecting / reflecting compression and decompression behavior
    property GrayScale: Boolean read FGrayScale write FGrayScale;
    property ProgressiveEncoding: Boolean read FProgressiveEncoding write FProgressiveEncoding;

    // Compression options
    property CompressionQuality: TJPEGQualityRange read FQuality write FQuality;

    // Decompression options
    property Scale: TJPEGScale read FScale write FScale;
    property Bitmap: TBitmap read FBitmap write FBitmap;
    property Image: TCustomMemoryStream read FImage write FImage;
  end;

  TJPEGDefaults = record
    CompressionQuality: TJPEGQualityRange;
    Grayscale: Boolean;
    ProgressiveEncoding: Boolean;
    Scale: TJPEGScale;
  end;

var   // Default settings for all new TJPEGImage instances
  JPEGDefaults: TJPEGDefaults = (
    CompressionQuality: 90;
    Grayscale: False;
    ProgressiveEncoding: True;
    Scale: jsFullSize;
  );

//------------------------ InLine -----------------------------------------

{$Z4}  // Minimum enum size = dword
{$IFDEF JPEGSO}
{$A4}  // if using the .so on Linux, align on DWORD boundaries.
{$ENDIF}
{$IFDEF MSWINDOWS}
{$A4} // Windows requires alignment on DWORD boundaries.
{$ENDIF MSWINDOWS}

const
  JPEG_LIB_VERSION = 62;        { Version 6b }

// JPEG_RST0     = $D0;  { RST0 marker code }
//  JPEG_EOI      = $D9;  { EOI marker code }
//  JPEG_APP0     = $E0;  { APP0 marker code }
//  JPEG_COM      = $FE;  { COM marker code }

//  DCTSIZE             = 8;      { The basic DCT block is 8x8 samples }
//  DCTSIZE2            = 64;     { DCTSIZE squared; # of elements in a block }
  NUM_QUANT_TBLS      = 4;      { Quantization tables are numbered 0..3 }
  NUM_HUFF_TBLS       = 4;      { Huffman tables are numbered 0..3 }
  NUM_ARITH_TBLS      = 16;     { Arith-coding tables are numbered 0..15 }
  MAX_COMPS_IN_SCAN   = 4;      { JPEG limit on # of components in one scan }
//  MAX_SAMP_FACTOR     = 4;      { JPEG limit on sampling factors }
  C_MAX_BLOCKS_IN_MCU = 10;     { compressor's limit on blocks per MCU }
  D_MAX_BLOCKS_IN_MCU = 10;     { decompressor's limit on blocks per MCU }
//  MAX_COMPONENTS = 10;          { maximum number of image components (color channels) }

//  MAXJSAMPLE = 255;
//  CENTERJSAMPLE = 128;

type
  JSAMPLE = byte;
//  GETJSAMPLE = integer;
//  JCOEF = integer;
//  JCOEF_PTR = ^JCOEF;
//  UINT8 = byte;
//  UINT16 = Word;
//  UINT = Cardinal;
//  INT16 = SmallInt;
//  INT32 = Integer;
//  INT32PTR = ^INT32;
  JDIMENSION = Cardinal;

  JOCTET = Byte;
  jTOctet = 0..(MaxInt div SizeOf(JOCTET))-1;
  JOCTET_FIELD = array[jTOctet] of JOCTET;
  JOCTET_FIELD_PTR = ^JOCTET_FIELD;
  JOCTETPTR = ^JOCTET;

  JSAMPLE_PTR = ^JSAMPLE;
  JSAMPROW_PTR = ^JSAMPROW;

  jTSample = 0..(MaxInt div SIZEOF(JSAMPLE))-1;
  JSAMPLE_ARRAY = Array[jTSample] of JSAMPLE;  {far}
  JSAMPROW = ^JSAMPLE_ARRAY;  { ptr to one image row of pixel samples. }

  jTRow = 0..(MaxInt div SIZEOF(JSAMPROW))-1;
  JSAMPROW_ARRAY = Array[jTRow] of JSAMPROW;
  JSAMPARRAY = ^JSAMPROW_ARRAY;  { ptr to some rows (a 2-D sample array) }

//  jTArray = 0..(MaxInt div SIZEOF(JSAMPARRAY))-1;
//  JSAMP_ARRAY = Array[jTArray] of JSAMPARRAY;
//  JSAMPIMAGE = ^JSAMP_ARRAY;  { a 3-D sample array: top index is color }

{ Known color spaces. }

type
  J_COLOR_SPACE = (
	JCS_UNKNOWN,            { error/unspecified }
	JCS_GRAYSCALE,          { monochrome }
	JCS_RGB,                { red/green/blue }
	JCS_YCbCr,              { Y/Cb/Cr (also known as YUV) }
	JCS_CMYK,               { C/M/Y/K }
	JCS_YCCK                { Y/Cb/Cr/K }
                  );

{ DCT/IDCT algorithm options. }

type
  J_DCT_METHOD = (
	JDCT_ISLOW,		{ slow but accurate integer algorithm }
	JDCT_IFAST,		{ faster, less accurate integer method }
	JDCT_FLOAT		{ floating-point: accurate, fast on fast HW (Pentium)}
                 );

{ Dithering options for decompression. }

type
  J_DITHER_MODE = (
    JDITHER_NONE,               { no dithering }
    JDITHER_ORDERED,            { simple ordered dither }
    JDITHER_FS                  { Floyd-Steinberg error diffusion dither }
                  );

{ Error handler }

const
//  JMSG_LENGTH_MAX  = 200;  { recommended size of format_message buffer }
  JMSG_STR_PARM_MAX = 80;

//  JPOOL_PERMANENT = 0;  // lasts until master record is destroyed
  JPOOL_IMAGE	    = 1;	 // lasts until done with image/datastream

type
  jpeg_error_mgr_ptr = ^jpeg_error_mgr;
  jpeg_progress_mgr_ptr = ^jpeg_progress_mgr;

  j_common_ptr = ^jpeg_common_struct;
  j_compress_ptr = ^jpeg_compress_struct;
  j_decompress_ptr = ^jpeg_decompress_struct;

{ Routine signature for application-supplied marker processing methods.
  Need not pass marker code since it is stored in cinfo^.unread_marker. }

//  jpeg_marker_parser_method = function(cinfo : j_decompress_ptr) : LongBool; {$IFDEF LINUX} cdecl; {$ENDIF}

  { The decompressor can save APPn and COM markers in a list of these: }

  jpeg_saved_marker_ptr = ^jpeg_marker_struct;

  jpeg_marker_struct = record
    next: jpeg_saved_marker_ptr;	{ next in list, or NULL }
    marker: Byte;			{ marker code: JPEG_COM, or JPEG_APP0+n }
    original_length: LongWord;	{ # bytes of data in the file }
    data_length: LongWord;	{ # bytes of data saved at data[] }
    data: JOCTETPTR;		{ the data contained in the marker }
    { the marker length word is not counted in data_length or original_length }
  end;

{ Marker reading & parsing }
//  jpeg_marker_reader_ptr = ^jpeg_marker_reader;
//  jpeg_marker_reader = record
//    reset_marker_reader : procedure(cinfo : j_decompress_ptr); {$IFDEF LINUX} cdecl; {$ENDIF}
//    { Read markers until SOS or EOI.
//      Returns same codes as are defined for jpeg_consume_input:
//      JPEG_SUSPENDED, JPEG_REACHED_SOS, or JPEG_REACHED_EOI. }
//
////    read_markers : function (cinfo : j_decompress_ptr) : Integer; {$IFDEF LINUX} cdecl; {$ENDIF}
////    { Read a restart marker --- exported for use by entropy decoder only }
////    read_restart_marker : jpeg_marker_parser_method;
////    { Application-overridable marker processing methods }
////    process_COM : jpeg_marker_parser_method;
////    process_APPn : Array[0..16-1] of jpeg_marker_parser_method;
//
//    { State of marker reader --- nominally internal, but applications
//      supplying COM or APPn handlers might like to know the state. }
//
//    saw_SOI : LongBool;            { found SOI? }
//    saw_SOF : LongBool;            { found SOF? }
//    next_restart_num : Integer;    { next restart number expected (0-7) }
//    discarded_bytes : UINT;        { # of bytes skipped looking for a marker }
//  end;

  {int8array = Array[0..8-1] of int;}
  int8array = Array[0..8-1] of Integer;

  jpeg_error_mgr = record
    { Error exit handler: does not return to caller }
    error_exit : procedure  (cinfo : j_common_ptr); {$IFDEF LINUX} cdecl; {$ENDIF}
    { Conditionally emit a trace or warning message }
    emit_message : procedure (cinfo : j_common_ptr; msg_level : Integer); {$IFDEF LINUX} cdecl; {$ENDIF}
    { Routine that actually outputs a trace or error message }
    output_message : procedure (cinfo : j_common_ptr); {$IFDEF LINUX} cdecl; {$ENDIF}
    { Format a message string for the most recent JPEG error or message }
    format_message : procedure  (cinfo : j_common_ptr; buffer: PChar); {$IFDEF LINUX} cdecl; {$ENDIF}
    { Reset error state variables at start of a new image }
    reset_error_mgr : procedure (cinfo : j_common_ptr); {$IFDEF LINUX} cdecl; {$ENDIF}

    { The message ID code and any parameters are saved here.
      A message can have one string parameter or up to 8 int parameters. }

    msg_code : Integer;

    msg_parm : record
      case byte of
      0:(i : int8array);
      1:(s : array[0..JMSG_STR_PARM_MAX - 1] of char);
    end;
    trace_level : Integer;     { max msg_level that will be displayed }
    num_warnings : Integer;    { number of corrupt-data warnings }
    jpeg_message_table: ^PChar; { Library errors }
    last_jpeg_message: Integer; { Table contains strings 0..last_jpeg_message }
    { Second table can be added by application (see cjpeg/djpeg for example).
      It contains strings numbered first_addon_message..last_addon_message.
    }
    addon_message_table: ^PChar; { Non-library errors }
    first_addon_message: Integer; { code for first string in addon table }
    last_addon_message: Integer;  { code for last string in addon table }
  end;


{ Data destination object for compression }
  jpeg_destination_mgr_ptr = ^jpeg_destination_mgr;
  jpeg_destination_mgr = record
    next_output_byte : JOCTETptr;  { => next byte to write in buffer }
    free_in_buffer : Longint;    { # of byte spaces remaining in buffer }

    init_destination : procedure (cinfo : j_compress_ptr); {$IFDEF LINUX} cdecl; {$ENDIF}
    empty_output_buffer : function (cinfo : j_compress_ptr) : LongBool; {$IFDEF LINUX} cdecl; {$ENDIF}
    term_destination : procedure (cinfo : j_compress_ptr); {$IFDEF LINUX} cdecl; {$ENDIF}
  end;


{ Data source object for decompression }

  jpeg_source_mgr_ptr = ^jpeg_source_mgr;
  jpeg_source_mgr = record
    next_input_byte : JOCTETptr;      { => next byte to read from buffer }
    bytes_in_buffer : Longint;       { # of bytes remaining in buffer }

    init_source : procedure  (cinfo : j_decompress_ptr); {$IFDEF LINUX} cdecl; {$ENDIF}
    fill_input_buffer : function (cinfo : j_decompress_ptr) : LongBool; {$IFDEF LINUX} cdecl; {$ENDIF}
    skip_input_data : procedure (cinfo : j_decompress_ptr; num_bytes : Longint); {$IFDEF LINUX} cdecl; {$ENDIF}
    resync_to_restart : function (cinfo : j_decompress_ptr;
                                  desired : Integer) : LongBool; {$IFDEF LINUX} cdecl; {$ENDIF}
    term_source : procedure (cinfo : j_decompress_ptr); {$IFDEF LINUX} cdecl; {$ENDIF}
  end;

{ JPEG library memory manger routines }
  jpeg_memory_mgr_ptr = ^jpeg_memory_mgr;
  jpeg_memory_mgr = record
    { Method pointers }
    alloc_small : function (cinfo : j_common_ptr;
                            pool_id, sizeofobject: Integer): pointer; {$IFDEF LINUX} cdecl; {$ENDIF}
    alloc_large : function (cinfo : j_common_ptr;
                            pool_id, sizeofobject: Integer): pointer; {$IFDEF LINUX} cdecl; {$ENDIF}
    alloc_sarray : function (cinfo : j_common_ptr; pool_id : Integer;
                             samplesperrow : JDIMENSION;
                             numrows : JDIMENSION) : JSAMPARRAY; {$IFDEF LINUX} cdecl; {$ENDIF}
    alloc_barray : pointer;
    request_virt_sarray : pointer;
    request_virt_barray : pointer;
    realize_virt_arrays : pointer;
    access_virt_sarray : pointer;
    access_virt_barray : pointer;
    free_pool : pointer;
    self_destruct : pointer;
    max_memory_to_use : Longint;

    { Maximum allocation request accepted by alloc_large. }
    max_alloc_chunk: Longint;
  end;

    { Fields shared with jpeg_decompress_struct }
  jpeg_common_struct = record
    err : jpeg_error_mgr_ptr;        { Error handler module }
    mem : jpeg_memory_mgr_ptr;          { Memory manager module }
    progress : jpeg_progress_mgr_ptr;   { Progress monitor, or NIL if none }
    client_data: Pointer;            { Available for use by application }
    is_decompressor : LongBool;      { so common code can tell which is which }
    global_state : Integer;          { for checking call sequence validity }
  end;

{ Progress monitor object }

  jpeg_progress_mgr = record
    progress_monitor : procedure(const cinfo : jpeg_common_struct); {$IFDEF LINUX} cdecl; {$ENDIF}
    pass_counter : Integer;     { work units completed in this pass }
    pass_limit : Integer;       { total number of work units in this pass }
    completed_passes : Integer;	{ passes completed so far }
    total_passes : Integer;     { total number of passes expected }
    // extra Delphi info
    instance: TJPEGImage;       // ptr to current TJPEGImage object
    last_pass: Integer;
    last_pct: Integer;
    last_time: Integer;
    last_scanline: Integer;
  end;


{ Master record for a compression instance }

{$IFDEF MSWINDOWS}
  jpeg_compress_struct = record
{$ENDIF}
{$IFDEF LINUX}
  jpeg_compress_struct = packed record
{$ENDIF}
    common: jpeg_common_struct;

    dest : jpeg_destination_mgr_ptr; { Destination for compressed data }

  { Description of source image --- these fields must be filled in by
    outer application before starting compression.  in_color_space must
    be correct before you can even call jpeg_set_defaults(). }

    image_width : JDIMENSION;         { input image width }
    image_height : JDIMENSION;        { input image height }
    input_components : Integer;       { # of color components in input image }
    in_color_space : J_COLOR_SPACE;   { colorspace of input image }
    input_gamma : double;             { image gamma of input image }

    // Compression parameters
    data_precision : Integer;             { bits of precision in image data }
    num_components : Integer;             { # of color components in JPEG image }
    jpeg_color_space : J_COLOR_SPACE;     { colorspace of JPEG image }
    comp_info : Pointer;
    quant_tbl_ptrs: Array[0..NUM_QUANT_TBLS-1] of Pointer;
    dc_huff_tbl_ptrs : Array[0..NUM_HUFF_TBLS-1] of Pointer;
    ac_huff_tbl_ptrs : Array[0..NUM_HUFF_TBLS-1] of Pointer;
    arith_dc_L : Array[0..NUM_ARITH_TBLS-1] of UINT8; { L values for DC arith-coding tables }
    arith_dc_U : Array[0..NUM_ARITH_TBLS-1] of UINT8; { U values for DC arith-coding tables }
    arith_ac_K : Array[0..NUM_ARITH_TBLS-1] of UINT8; { Kx values for AC arith-coding tables }
    num_scans : Integer;		 { # of entries in scan_info array }
    scan_info : Pointer;     { script for multi-scan file, or NIL }
    raw_data_in : LongBool;        { TRUE=caller supplies downsampled data }
    arith_code : LongBool;         { TRUE=arithmetic coding, FALSE=Huffman }
    optimize_coding : LongBool;    { TRUE=optimize entropy encoding parms }
    CCIR601_sampling : LongBool;   { TRUE=first samples are cosited }
    smoothing_factor : Integer;       { 1..100, or 0 for no input smoothing }
    dct_method : J_DCT_METHOD;    { DCT algorithm selector }
    restart_interval : UINT;      { MCUs per restart, or 0 for no restart }
    restart_in_rows : Integer;        { if > 0, MCU rows per restart interval }

    { Parameters controlling emission of special markers. }
    write_JFIF_header : LongBool;  { should a JFIF marker be written? }
    JFIF_major_version: UINT8;      { What to write for a JFIF version number }
    JFIF_minor_version: UINT8;
    { These three values are not used by the JPEG code, merely copied }
    { into the JFIF APP0 marker.  density_unit can be 0 for unknown, }
    { 1 for dots/inch, or 2 for dots/cm.  Note that the pixel aspect }
    { ratio is defined by X_density/Y_density even when density_unit=0. }
    density_unit : UINT8;         { JFIF code for pixel size units }
    X_density : UINT16;           { Horizontal pixel density }
    Y_density : UINT16;           { Vertical pixel density }
    write_Adobe_marker : LongBool; { should an Adobe marker be written? }

    { State variable: index of next scanline to be written to
      jpeg_write_scanlines().  Application may use this to control its
      processing loop, e.g., "while (next_scanline < image_height)". }

    next_scanline : JDIMENSION;   { 0 .. image_height-1  }

    { Remaining fields are known throughout compressor, but generally
      should not be touched by a surrounding application. }
    progressive_mode : LongBool;   { TRUE if scan script uses progressive mode }
    max_h_samp_factor : Integer;      { largest h_samp_factor }
    max_v_samp_factor : Integer;      { largest v_samp_factor }
    total_iMCU_rows : JDIMENSION; { # of iMCU rows to be input to coef ctlr }
    comps_in_scan : Integer;          { # of JPEG components in this scan }
    cur_comp_info : Array[0..MAX_COMPS_IN_SCAN-1] of Pointer;
    MCUs_per_row : JDIMENSION;    { # of MCUs across the image }
    MCU_rows_in_scan : JDIMENSION;{ # of MCU rows in the image }
    blocks_in_MCU : Integer;          { # of DCT blocks per MCU }
    MCU_membership : Array[0..C_MAX_BLOCKS_IN_MCU-1] of Integer;
    Ss, Se, Ah, Al : Integer;         { progressive JPEG parameters for scan }

    { Links to compression subobjects (methods and private variables of modules) }
    master : Pointer;
    main : Pointer;
    prep : Pointer;
    coef : Pointer;
    marker : Pointer;
    cconvert : Pointer;
    downsample : Pointer;
    fdct : Pointer;
    entropy : Pointer;
    script_space: Pointer;  { workspace for jpeg_simple_progression }
    script_space_size: Integer;
  end;


{ Master record for a decompression instance }

  jpeg_decompress_struct = record
    common: jpeg_common_struct;

    { Source of compressed data }
    src : jpeg_source_mgr_ptr;

    { Basic description of image --- filled in by jpeg_read_header(). }
    { Application may inspect these values to decide how to process image. }

    image_width : JDIMENSION;      { nominal image width (from SOF marker) }
    image_height : JDIMENSION;     { nominal image height }
    num_components : Integer;          { # of color components in JPEG image }
    jpeg_color_space : J_COLOR_SPACE; { colorspace of JPEG image }

    { Decompression processing parameters }
    out_color_space : J_COLOR_SPACE; { colorspace for output }
    scale_num, scale_denom : uint ;  { fraction by which to scale image }
    output_gamma : double;           { image gamma wanted in output }
    buffered_image : LongBool;        { TRUE=multiple output passes }
    raw_data_out : LongBool;          { TRUE=downsampled data wanted }
    dct_method : J_DCT_METHOD;       { IDCT algorithm selector }
    do_fancy_upsampling : LongBool;   { TRUE=apply fancy upsampling }
    do_block_smoothing : LongBool;    { TRUE=apply interblock smoothing }
    quantize_colors : LongBool;       { TRUE=colormapped output wanted }
    { the following are ignored if not quantize_colors: }
    dither_mode : J_DITHER_MODE;     { type of color dithering to use }
    two_pass_quantize : LongBool;     { TRUE=use two-pass color quantization }
    desired_number_of_colors : Integer;  { max # colors to use in created colormap }
    { these are significant only in buffered-image mode: }
    enable_1pass_quant : LongBool;    { enable future use of 1-pass quantizer }
    enable_external_quant : LongBool; { enable future use of external colormap }
    enable_2pass_quant : LongBool;    { enable future use of 2-pass quantizer }

    { Description of actual output image that will be returned to application.
      These fields are computed by jpeg_start_decompress().
      You can also use jpeg_calc_output_dimensions() to determine these values
      in advance of calling jpeg_start_decompress(). }

    output_width : JDIMENSION;       { scaled image width }
    output_height: JDIMENSION;       { scaled image height }
    out_color_components : Integer;  { # of color components in out_color_space }
    output_components : Integer;     { # of color components returned }
    { output_components is 1 (a colormap index) when quantizing colors;
      otherwise it equals out_color_components. }

    rec_outbuf_height : Integer;     { min recommended height of scanline buffer }
    { If the buffer passed to jpeg_read_scanlines() is less than this many
      rows high, space and time will be wasted due to unnecessary data
      copying. Usually rec_outbuf_height will be 1 or 2, at most 4. }

    { When quantizing colors, the output colormap is described by these
      fields. The application can supply a colormap by setting colormap
      non-NIL before calling jpeg_start_decompress; otherwise a colormap
      is created during jpeg_start_decompress or jpeg_start_output. The map
      has out_color_components rows and actual_number_of_colors columns. }

    actual_number_of_colors : Integer;      { number of entries in use }
    colormap : JSAMPARRAY;              { The color map as a 2-D pixel array }

    { State variables: these variables indicate the progress of decompression.
      The application may examine these but must not modify them. }

    { Row index of next scanline to be read from jpeg_read_scanlines().
      Application may use this to control its processing loop, e.g.,
      "while (output_scanline < output_height)". }

    output_scanline : JDIMENSION; { 0 .. output_height-1  }

    { Current input scan number and number of iMCU rows completed in scan.
      These indicate the progress of the decompressor input side. }

    input_scan_number : Integer;      { Number of SOS markers seen so far }
    input_iMCU_row : JDIMENSION;  { Number of iMCU rows completed }

    { The "output scan number" is the notional scan being displayed by the
      output side.  The decompressor will not allow output scan/row number
      to get ahead of input scan/row, but it can fall arbitrarily far behind.}

    output_scan_number : Integer;     { Nominal scan number being displayed }
    output_iMCU_row : Integer;        { Number of iMCU rows read }

    coef_bits : Pointer;

    { Internal JPEG parameters --- the application usually need not look at
      these fields.  Note that the decompressor output side may not use
      any parameters that can change between scans. }

    { Quantization and Huffman tables are carried forward across input
      datastreams when processing abbreviated JPEG datastreams. }

    quant_tbl_ptrs : Array[0..NUM_QUANT_TBLS-1] of Pointer;
    dc_huff_tbl_ptrs : Array[0..NUM_HUFF_TBLS-1] of Pointer;
    ac_huff_tbl_ptrs : Array[0..NUM_HUFF_TBLS-1] of Pointer;

    { These parameters are never carried across datastreams, since they
      are given in SOF/SOS markers or defined to be reset by SOI. }
    data_precision : Integer;          { bits of precision in image data }
    comp_info : Pointer;
    progressive_mode : LongBool;    { TRUE if SOFn specifies progressive mode }
    arith_code : LongBool;          { TRUE=arithmetic coding, FALSE=Huffman }
    arith_dc_L : Array[0..NUM_ARITH_TBLS-1] of UINT8; { L values for DC arith-coding tables }
    arith_dc_U : Array[0..NUM_ARITH_TBLS-1] of UINT8; { U values for DC arith-coding tables }
    arith_ac_K : Array[0..NUM_ARITH_TBLS-1] of UINT8; { Kx values for AC arith-coding tables }

    restart_interval : UINT; { MCUs per restart interval, or 0 for no restart }

    { These fields record data obtained from optional markers recognized by
      the JPEG library. }
    saw_JFIF_marker : LongBool;  { TRUE iff a JFIF APP0 marker was found }
    { Data copied from JFIF marker: only valid if saw_JFIF_marker is TRUE: }
    JFIF_major_version: UINT8;    { JFIF version number }
    JFIF_minor_version: UINT8;
    density_unit : UINT8;       { JFIF code for pixel size units }
    X_density : UINT16;         { Horizontal pixel density }
    Y_density : UINT16;         { Vertical pixel density }
    saw_Adobe_marker : LongBool; { TRUE iff an Adobe APP14 marker was found }
    Adobe_transform : UINT8;    { Color transform code from Adobe marker }

    CCIR601_sampling : LongBool; { TRUE=first samples are cosited }

    { Aside from the specific data retained from APPn markers known to the
      library, the uninterpreted contents of any or all APPn and COM markers
      can be saved in a list for examination by the application. }
    marker_list: jpeg_saved_marker_ptr; { Head of list of saved markers }

    { Remaining fields are known throughout decompressor, but generally
      should not be touched by a surrounding application. }
    max_h_samp_factor : Integer;    { largest h_samp_factor }
    max_v_samp_factor : Integer;    { largest v_samp_factor }
    min_DCT_scaled_size : Integer;  { smallest DCT_scaled_size of any component }
    total_iMCU_rows : JDIMENSION; { # of iMCU rows in image }
    sample_range_limit : Pointer;   { table for fast range-limiting }

    { These fields are valid during any one scan.
      They describe the components and MCUs actually appearing in the scan.
      Note that the decompressor output side must not use these fields. }
    comps_in_scan : Integer;           { # of JPEG components in this scan }
    cur_comp_info : Array[0..MAX_COMPS_IN_SCAN-1] of Pointer;
    MCUs_per_row : JDIMENSION;     { # of MCUs across the image }
    MCU_rows_in_scan : JDIMENSION; { # of MCU rows in the image }
    blocks_in_MCU : JDIMENSION;    { # of DCT blocks per MCU }
    MCU_membership : Array[0..D_MAX_BLOCKS_IN_MCU-1] of Integer;
    Ss, Se, Ah, Al : Integer;          { progressive JPEG parameters for scan }

    { This field is shared between entropy decoder and marker parser.
      It is either zero or the code of a JPEG marker that has been
      read from the data source, but has not yet been processed. }
    unread_marker : Integer;

    { Links to decompression subobjects
      (methods, private variables of modules) }
    master : Pointer;
    main : Pointer;
    coef : Pointer;
    post : Pointer;
    inputctl : Pointer;
    marker : Pointer;
    entropy : Pointer;
    idct : Pointer;
    upsample : Pointer;
    cconvert : Pointer;
    cquantize : Pointer;
  end;

  TJPEGContext = record
    err: jpeg_error_mgr;
    progress: jpeg_progress_mgr;
    FinalDCT: J_DCT_METHOD;
    FinalTwoPassQuant: Boolean;
    FinalDitherMode: J_DITHER_MODE;
    case byte of
      0: (common: jpeg_common_struct);
      1: (d: jpeg_decompress_struct);
      2: (c: jpeg_compress_struct);
  end;

{ Decompression startup: read start of JPEG datastream to see what's there
   function jpeg_read_header (cinfo : j_decompress_ptr;
                              require_image : LongBool) : Integer;
  Return value is one of: }
const
//  JPEG_SUSPENDED              = 0; { Suspended due to lack of input data }
//  JPEG_HEADER_OK              = 1; { Found valid image datastream }
//  JPEG_HEADER_TABLES_ONLY     = 2; { Found valid table-specs-only datastream }
{ If you pass require_image = TRUE (normal case), you need not check for
  a TABLES_ONLY return code; an abbreviated file will cause an error exit.
  JPEG_SUSPENDED is only possible if you use a data source module that can
  give a suspension return (the stdio source module doesn't). }


{ function jpeg_consume_input (cinfo : j_decompress_ptr) : Integer;
  Return value is one of: }

//  JPEG_REACHED_SOS            = 1; { Reached start of new scan }
  JPEG_REACHED_EOI            = 2; { Reached end of image }
//  JPEG_ROW_COMPLETED          = 3; { Completed one iMCU row }
//  JPEG_SCAN_COMPLETED         = 4; { Completed last iMCU row of a scan }

{$IFDEF WIN32}
{$L obj\jdapimin.obj}
{$L obj\jmemmgr.obj}
{$L obj\jmemnobs.obj}
{$L obj\jdinput.obj}
{$L obj\jdatasrc.obj}
{$L obj\jdapistd.obj}
{$L obj\jdmaster.obj}
{$L obj\jdphuff.obj}
{$L obj\jdhuff.obj}
{$L obj\jdmerge.obj}
{$L obj\jdcolor.obj}
{$L obj\jquant1.obj}
{$L obj\jquant2.obj}
{$L obj\jdmainct.obj}
{$L obj\jdcoefct.obj}
{$L obj\jdpostct.obj}
{$L obj\jddctmgr.obj}
{$L obj\jdsample.obj}
{$L obj\jidctflt.obj}
{$L obj\jidctfst.obj}
{$L obj\jidctint.obj}
{$L obj\jidctred.obj}
{$L obj\jdmarker.obj}
{$L obj\jutils.obj}
{$L obj\jcomapi.obj}
{$ENDIF}

{$IFDEF LINUX}
{$IFNDEF JPEGSO}
{$L jdapimin.o}
{$L jmemmgr.o}
{$L jmemnobs.o}
{$L jdinput.o}
{$L jdatasrc.o}
{$L jdapistd.o}
{$L jdmaster.o}
{$L jdphuff.o}
{$L jdhuff.o}
{$L jdmerge.o}
{$L jdcolor.o}
{$L jquant1.o}
{$L jquant2.o}
{$L jdmainct.o}
{$L jdcoefct.o}
{$L jdpostct.o}
{$L jddctmgr.o}
{$L jdsample.o}
{$L jidctflt.o}
{$L jidctfst.o}
{$L jidctint.o}
{$L jidctred.o}
{$L jdmarker.o}
{$L jutils.o}
{$L jcomapi.o}
{$ENDIF}
{$ENDIF}

procedure jpeg_CreateDecompress (var cinfo : jpeg_decompress_struct;
  version : integer; structsize : integer); {$IFDEF LINUX} cdecl; {$ENDIF}
  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_CreateDecompress' {$ENDIF};InLine;
procedure jpeg_stdio_src(var cinfo: jpeg_decompress_struct;
  input_file: TStream);  {$IFDEF LINUX} cdecl; {$ENDIF}
  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_stdio_src' {$ENDIF};InLine;
procedure jpeg_read_header(var cinfo: jpeg_decompress_struct;
  RequireImage: LongBool); {$IFDEF LINUX} cdecl; {$ENDIF}
  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_read_header' {$ENDIF};InLine;
//procedure jpeg_calc_output_dimensions(var cinfo: jpeg_decompress_struct); {$IFDEF LINUX} cdecl; {$ENDIF}
//  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_calc_output_dimensions' {$ENDIF};InLine;
//procedure jpeg_save_markers(var cinfo: jpeg_decompress_struct; marker_code: Integer; length_limit: UINT); {$IFDEF LINUX} cdecl; {$ENDIF}
//  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_save_markers' {$ENDIF};InLine;
function jpeg_start_decompress(var cinfo: jpeg_decompress_struct): Longbool; {$IFDEF LINUX} cdecl; {$ENDIF}
  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_start_decompress' {$ENDIF};InLine;
function jpeg_read_scanlines(var cinfo: jpeg_decompress_struct;
	scanlines: JSAMPARRAY; max_lines: JDIMENSION): JDIMENSION; {$IFDEF LINUX} cdecl; {$ENDIF}
  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_read_scanlines' {$ENDIF};InLine;
function jpeg_finish_decompress(var cinfo: jpeg_decompress_struct): Longbool; {$IFDEF LINUX} cdecl; {$ENDIF}
  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_finish_decompress' {$ENDIF};InLine;
//procedure jpeg_destroy_decompress (var cinfo : jpeg_decompress_struct); {$IFDEF LINUX} cdecl; {$ENDIF}
//  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_destroy_decompress' {$ENDIF};InLine;
//function jpeg_has_multiple_scans(var cinfo: jpeg_decompress_struct): Longbool; {$IFDEF LINUX} cdecl; {$ENDIF}
//  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_has_multiple_scans' {$ENDIF};InLine;
function jpeg_consume_input(var cinfo: jpeg_decompress_struct): Integer; {$IFDEF LINUX} cdecl; {$ENDIF}
  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_consume_input' {$ENDIF};InLine;
function jpeg_start_output(var cinfo: jpeg_decompress_struct; scan_number: Integer): Longbool; {$IFDEF LINUX} cdecl; {$ENDIF}
  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_start_output' {$ENDIF};InLine;
function jpeg_finish_output(var cinfo: jpeg_decompress_struct): LongBool; {$IFDEF LINUX} cdecl; {$ENDIF}
  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_finish_output' {$ENDIF};InLine;
procedure jpeg_destroy(var cinfo: jpeg_common_struct); {$IFDEF LINUX} cdecl; {$ENDIF}
  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_destroy' {$ENDIF};InLine;

{$IFDEF WIN32}
{$L obj\jdatadst.obj}
{$L obj\jcparam.obj}
{$L obj\jcapistd.obj}
{$L obj\jcapimin.obj}
{$L obj\jcinit.obj}
{$L obj\jcmarker.obj}
{$L obj\jcmaster.obj}
{$L obj\jcmainct.obj}
{$L obj\jcprepct.obj}
{$L obj\jccoefct.obj}
{$L obj\jccolor.obj}
{$L obj\jcsample.obj}
{$L obj\jcdctmgr.obj}
{$L obj\jcphuff.obj}
{$L obj\jfdctint.obj}
{$L obj\jfdctfst.obj}
{$L obj\jfdctflt.obj}
{$L obj\jchuff.obj}
{$ENDIF}
{$IFDEF LINUX}
{$IFNDEF JPEGSO}
{$L jdatadst.o}
{$L jcparam.o}
{$L jcapistd.o}
{$L jcapimin.o}
{$L jcinit.o}
{$L jcmarker.o}
{$L jcmaster.o}
{$L jcmainct.o}
{$L jcprepct.o}
{$L jccoefct.o}
{$L jccolor.o}
{$L jcsample.o}
{$L jcdctmgr.o}
{$L jcphuff.o}
{$L jfdctint.o}
{$L jfdctfst.o}
{$L jfdctflt.o}
{$L jchuff.o}
{$ENDIF}
{$ENDIF}

procedure jpeg_CreateCompress (var cinfo : jpeg_compress_struct;
  version : integer; structsize : integer); {$IFDEF LINUX} cdecl; {$ENDIF}
  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_CreateCompress' {$ENDIF};InLine;
procedure jpeg_stdio_dest(var cinfo: jpeg_compress_struct;
  output_file: TStream); {$IFDEF LINUX} cdecl; {$ENDIF}
  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_stdio_dest' {$ENDIF};InLine;
procedure jpeg_set_defaults(var cinfo: jpeg_compress_struct); {$IFDEF LINUX} cdecl; {$ENDIF}
  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_set_defaults' {$ENDIF};InLine;
procedure jpeg_set_quality(var cinfo: jpeg_compress_struct; Quality: Integer;
  Baseline: Longbool); {$IFDEF LINUX} cdecl; {$ENDIF}
  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_set_quality' {$ENDIF};InLine;
procedure jpeg_set_colorspace(var cinfo: jpeg_compress_struct;
  colorspace: J_COLOR_SPACE); {$IFDEF LINUX} cdecl; {$ENDIF}
  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_set_colorspace' {$ENDIF};InLine;
procedure jpeg_simple_progression(var cinfo: jpeg_compress_struct); {$IFDEF LINUX} cdecl; {$ENDIF}
  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_simple_progression' {$ENDIF};InLine;
procedure jpeg_start_compress(var cinfo: jpeg_compress_struct;
  WriteAllTables: LongBool); {$IFDEF LINUX} cdecl; {$ENDIF}
  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_start_compress' {$ENDIF};InLine;
function jpeg_write_scanlines(var cinfo: jpeg_compress_struct;
  scanlines: JSAMPARRAY; max_lines: JDIMENSION): JDIMENSION; {$IFDEF LINUX} cdecl; {$ENDIF}
  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_write_scanlines' {$ENDIF};InLine;
procedure jpeg_finish_compress(var cinfo: jpeg_compress_struct); {$IFDEF LINUX} cdecl; {$ENDIF}
  external {$IFDEF JPEGSO} 'libjpeg.so' name 'jpeg_finish_compress' {$ENDIF};InLine;

procedure ProgressCallback(const cinfo: jpeg_common_struct); {$IFDEF LINUX} cdecl; export; {$ENDIF}InLine;

procedure JpegError(cinfo: j_common_ptr); {$IFDEF LINUX} cdecl; export; {$ENDIF}InLine;

procedure EmitMessage(cinfo: j_common_ptr; msg_level: Integer); {$IFDEF LINUX} cdecl; export; {$ENDIF}InLine;

procedure OutputMessage(cinfo: j_common_ptr); {$IFDEF LINUX} cdecl; export; {$ENDIF}InLine;

procedure FormatMessage(cinfo: j_common_ptr; buffer: PChar); {$IFDEF LINUX} cdecl; export; {$ENDIF}InLine;

procedure ResetErrorMgr(cinfo: j_common_ptr); {$IFDEF LINUX} cdecl; export; {$ENDIF}InLine;

const
  jpeg_std_error: jpeg_error_mgr = (
    error_exit: JpegError;
    emit_message: EmitMessage;
    output_message: OutputMessage;
    format_message: FormatMessage;
    reset_error_mgr: ResetErrorMgr);

type
  EJPEG = class(EInvalidGraphic);

implementation

uses JConsts;

{ The following types and external function declarations are used to
  call into functions of the Independent JPEG Group's (IJG) implementation
  of the JPEG image compression/decompression public standard.  The IJG
  library's C source code is compiled into OBJ files and linked into
  the Delphi application. Only types and functions needed by this unit
  are declared; all IJG internal structures are stubbed out with
  generic pointers to reduce internal source code congestion.

  IJG source code copyright (C) 1991-1996, Thomas G. Lane. }

// Stubs for external C RTL functions referenced by JPEG OBJ files.

{$IFDEF WIN32}
function _malloc(size: Integer): Pointer; cdecl;InLine;
begin
  GetMem(Result, size);
end;

procedure _free(P: Pointer); cdecl;InLine;
begin
  FreeMem(P);
end;

procedure _memset(P: Pointer; B: Byte; count: Integer);cdecl;InLine;
begin
  FillChar(P^, count, B);
end;

procedure _memcpy(dest, source: Pointer; count: Integer);cdecl;InLine;
begin
  Move(source^, dest^, count);
end;

function _fread(var buf; recsize, reccount: Integer; S: TStream): Integer; cdecl;InLine;
begin
  Result := S.Read(buf, recsize * reccount);
end;

function _fwrite(const buf; recsize, reccount: Integer; S: TStream): Integer; cdecl;InLine;
begin
  Result := S.Write(buf, recsize * reccount);
end;

function _fflush(S: TStream): Integer; cdecl;InLine;
begin
  Result := 0;
end;

function __ftol: Integer;
var
  f: double;
begin
  asm
    lea    eax, f             //  BC++ passes floats on the FPU stack
    fstp  qword ptr [eax]     //  Delphi passes floats on the CPU stack
  end;
  Result := Integer(Trunc(f));
end;

var
  __turboFloat: LongBool = False;
{$ENDIF}

{$IFDEF LINUX}
{$IFNDEF JPEGSO}
function malloc: Pointer; external 'libc.so.6' name 'malloc';InLine;
procedure free(P: Pointer); external 'libc.so.6' name 'free';InLine;
procedure memset(P: Pointer; B: Byte; count: Integer); external 'libc.so.6' name 'memset';InLine;
procedure memcpy(dest, source: Pointer; count: Integer);external 'libc.so.6' name 'memcpy';InLine;

function fread(var buf; recsize, reccount: Integer; S: TStream): Integer; cdecl;InLine;
begin
  Result := S.Read(buf, recsize * reccount);
end;

function fwrite(const buf; recsize, reccount: Integer; S: TStream): Integer; cdecl;InLine;
begin
  Result := S.Write(buf, recsize * reccount);
end;

function fflush(S: TStream): Integer; cdecl;InLine;
begin
  Result := 0;
end;

function ferror(S: TStream): LongBool; cdecl;InLine;
begin
  Result := S = nil;
end;
{$ENDIF}
{$ENDIF}

procedure InvalidOperation(const Msg: string); near;InLine;
begin
  raise EInvalidGraphicOperation.Create(Msg);
end;

procedure JpegError(cinfo: j_common_ptr); {$IFDEF LINUX} cdecl; export; {$ENDIF}InLine;
begin
  raise EJPEG.CreateFmt(sJPEGError,[cinfo^.err^.msg_code]);
end;

procedure EmitMessage(cinfo: j_common_ptr; msg_level: Integer); {$IFDEF LINUX} cdecl; export; {$ENDIF}InLine;
begin
  //!!
end;

procedure OutputMessage(cinfo: j_common_ptr); {$IFDEF LINUX} cdecl; export; {$ENDIF}InLine;
begin
  //!!
end;

procedure FormatMessage(cinfo: j_common_ptr; buffer: PChar); {$IFDEF LINUX} cdecl; export; {$ENDIF}InLine;
begin
  //!!
end;

procedure ResetErrorMgr(cinfo: j_common_ptr); {$IFDEF LINUX} cdecl; export; {$ENDIF}InLine;
begin
  cinfo^.err^.num_warnings := 0;
  cinfo^.err^.msg_code := 0;
end;

{$IFDEF JPEGSO}
const
  INPUT_BUF_SIZE = 4096;

type
  my_source_mgr = record
    pub: jpeg_source_mgr;
    infile: TStream;
    Buffer: JOCTETPTR;
    StartOfFile: Boolean;
  end;
  my_source_ptr = ^my_source_mgr;

procedure Init_Source(cinfo: j_decompress_ptr); cdecl; export;InLine;
begin
  my_source_ptr(cinfo.src).StartOfFile := True;
end;

function Fill_Input_Buffer(cinfo: j_decompress_ptr): LongBool; cdecl; export;InLine;
var
  nBytes: Integer;
  Src: my_source_ptr;
begin
  Src := my_source_ptr(cinfo.src);
  nBytes := Src.infile.Read(Src.Buffer^, INPUT_BUF_SIZE);

  if nBytes <= 0 then
  begin
    if Src.StartOfFile then
    begin
      cinfo.common.err.msg_code := 1000;
      cinfo.common.err.error_exit(j_common_ptr(cinfo));
    end;
    cinfo.common.err.msg_code := 1001;
    cinfo.common.err.emit_message(j_common_ptr(cinfo), -1);
    PChar(Src.Buffer)[0] := #$FF;
    PChar(Src.Buffer)[1] := Char(JPEG_EOI);
    nBytes := 2;
  end;
  Src.pub.next_input_byte := Src.Buffer;
  Src.pub.bytes_in_buffer := nBytes;
  Src.StartOfFile := False;
  Result := True;
end;

procedure Skip_Input_Data(cinfo: j_decompress_ptr; num_bytes: Longint); cdecl; export;InLine;
var
  Src: my_source_ptr;
begin
  Src := my_source_ptr(cinfo.src);
  if num_bytes > 0 then
  begin
    while num_bytes > Src.pub.bytes_in_buffer do
    begin
      Dec(num_bytes, Src.pub.bytes_in_buffer);
      Fill_Input_Buffer(cinfo);
    end;
    Inc(Integer(Src.pub.next_input_byte), num_bytes);
    Dec(Src.Pub.bytes_in_buffer, num_bytes);
  end;
end;

function jpeg_resync_to_restart(cinfo: j_decompress_ptr; desired: Integer): LongBool; cdecl;
  external 'libjpeg.so' name 'jpeg_resync_to_restart';InLine;

procedure Term_Source(cinfo: j_decompress_ptr); cdecl; export;InLine;
begin
  { no work nessesary here }
end;

procedure JPEGStdioSrc(var cinfo: jpeg_decompress_struct; Stream: TStream);InLine;
var
  Src: my_source_ptr;
begin
  if cinfo.src = nil then
  begin
    cinfo.src := cinfo.common.mem.alloc_small(j_common_ptr(@cinfo), JPOOL_PERMANENT,
      SizeOf(my_source_mgr));
    Src := my_source_ptr(cinfo.src);
    Src.Buffer := cinfo.common.mem.alloc_small(j_common_ptr(@cinfo), JPOOL_PERMANENT,
      INPUT_BUF_SIZE * SizeOf(JOCTET));
  end;
  Src := my_source_ptr(cinfo.src);
  Src.pub.init_source := Init_Source;
  Src.pub.fill_input_buffer := Fill_Input_Buffer;
  Src.pub.skip_input_data := Skip_Input_Data;
  Src.pub.resync_to_restart := jpeg_resync_to_restart;
  Src.pub.term_source := Term_Source;
  Src.infile := Stream;
  Src.pub.bytes_in_buffer := 0;
  Src.pub.next_input_byte := nil;
end;

type
  my_destination_mgr = record
    pub: jpeg_destination_mgr;
    outfile: TStream;
    Buffer: JOCTETPTR;
  end;
  my_destination_ptr = ^my_destination_mgr;

const
  OUTPUT_BUF_SIZE = 4096;

procedure init_destination(cinfo: j_compress_ptr); cdecl; export;InLine;
var
  Dest: my_destination_ptr;
begin
  Dest := my_destination_ptr(cinfo.dest);

  Dest.Buffer := cinfo.common.mem.alloc_small(j_common_ptr(@cinfo), JPOOL_IMAGE,
    OUTPUT_BUF_SIZE * SIZEOF(JOCTET));

  Dest.pub.next_output_byte := Dest.Buffer;
  Dest.pub.free_in_buffer := OUTPUT_BUF_SIZE;
end;

function empty_output_buffer(cinfo: j_compress_ptr): LongBool; cdecl; export;InLine;
var
  Dest: my_destination_ptr;
begin
  Dest := my_destination_ptr(cinfo.dest);

  if Dest.outFile.Write(Dest.Buffer^, OUTPUT_BUF_SIZE) <> OUTPUT_BUF_SIZE then
  begin
    cinfo.common.err.msg_code := 1002;
    cinfo.common.err.emit_message(j_common_ptr(cinfo), -1);
  end;

  Dest.pub.next_output_byte := Dest.Buffer;
  Dest.pub.free_in_buffer := OUTPUT_BUF_SIZE;

  Result := True;
end;

procedure term_destination(cinfo: j_compress_ptr); cdecl; export;InLine;
var
  Dest: my_destination_ptr;
  DataCount: Integer;
begin
  Dest := my_destination_ptr(cinfo.dest);
  DataCount := OUTPUT_BUF_SIZE - Dest.pub.free_in_buffer;
  if DataCount > 0 then
    if Dest.outFile.Write(Dest.Buffer^, DataCount) <> DataCount then
    begin
      cinfo.common.err.msg_code := 1002;
      cinfo.common.err.emit_message(j_common_ptr(cinfo), -1);
    end;
end;

procedure JPEGStdioDest(var cinfo: jpeg_compress_struct; outfile: TStream);InLine;
var
  Dest: my_destination_ptr;
begin

  if cinfo.dest = nil then
    cinfo.dest := cinfo.common.mem.alloc_small(j_common_ptr(@cinfo), JPOOL_PERMANENT,
      SizeOf(my_destination_mgr));

  Dest := my_destination_ptr(cinfo.dest);
  Dest.pub.init_destination := init_destination;
  Dest.pub.empty_output_buffer := empty_output_buffer;
  Dest.pub.term_destination := term_destination;
  Dest.outfile := outfile;
end;

{$ENDIF}

constructor TJPEGImage.Create;
begin
  inherited Create;
  FQuality := JPEGDefaults.CompressionQuality;
  FGrayscale := JPEGDefaults.Grayscale;
  FProgressiveEncoding := JPEGDefaults.ProgressiveEncoding;
  FScale := JPEGDefaults.Scale;
  FImage:=TMemoryStream.Create;
  FBitmap := TBitmap.Create;
end;

destructor TJPEGImage.Destroy;
begin
  FBitmap.Free;
  FImage.Free;
  inherited Destroy;
end;

procedure ProgressCallback(const cinfo: jpeg_common_struct); {$IFDEF LINUX} cdecl; export; {$ENDIF}
var
  Ticks: DWORD;
  R: TRect;
  temp: DWORD;
begin
  if (cinfo.progress = nil) or (cinfo.progress^.instance = nil) then Exit;
  with cinfo.progress^ do
  begin
    Ticks := GetTickCount;
    if (Ticks - DWORD(last_time)) < 500 then Exit;
    temp := DWORD(last_time);
    DWORD(last_time) := Ticks;
    if temp = 0 then Exit;
    if cinfo.is_decompressor then
      with j_decompress_ptr(@cinfo)^ do
      begin
        R := Rect(0, last_scanline, output_width, output_scanline);
        if R.Bottom < last_scanline then
          R.Bottom := output_height;
      end
    else
      R := Rect(0,0,0,0);
    temp := DWORD(Trunc(100.0*(completed_passes + (pass_counter/pass_limit))/total_passes));
    if temp = DWORD(last_pct) then Exit;
    last_pct := temp;
    if cinfo.is_decompressor then
      last_scanline := j_decompress_ptr(@cinfo)^.output_scanline;
  end;
end;

procedure ReleaseContext(var jc: TJPEGContext);InLine;
begin
  if jc.common.err = nil then Exit;
  jpeg_destroy(jc.common);
  jc.common.err := nil;
end;

procedure InitDecompressor(Obj: TJPEGImage; var jc: TJPEGContext);InLine;
begin
  FillChar(jc, sizeof(jc), 0);
  jc.err := jpeg_std_error;
  jc.common.err := @jc.err;

  jpeg_CreateDecompress(jc.d, JPEG_LIB_VERSION, sizeof(jc.d));
  with Obj do
  try
    jc.progress.progress_monitor := ProgressCallback;
    jc.progress.instance := Obj;
    jc.common.progress := @jc.progress;

    Obj.FImage.Position := 0;
{$IFNDEF JPEGSO}
    jpeg_stdio_src(jc.d, FImage);
{$ELSE}
    JpegStdioSrc(jc.d, FImage.FData);
{$ENDIF}
    jpeg_read_header(jc.d, TRUE);

    jc.d.scale_num := 1;
    jc.d.scale_denom := 1 shl Byte(FScale);
    jc.d.do_block_smoothing := False;

    if FGrayscale then jc.d.out_color_space := JCS_GRAYSCALE;
    if jc.d.out_color_space = JCS_GRAYSCALE then
    begin
      jc.d.quantize_colors := True;
      jc.d.desired_number_of_colors := 236;
    end;

//    if FPerformance = jpBestSpeed then
//    begin
      jc.d.dct_method := JDCT_IFAST;
      jc.d.two_pass_quantize := False;
      jc.d.do_fancy_upsampling := False;  //  !! AV inside jpeglib
      jc.d.dither_mode := JDITHER_ORDERED;
//    end;

    jc.FinalDCT := jc.d.dct_method;
    jc.FinalTwoPassQuant := jc.d.two_pass_quantize;
    jc.FinalDitherMode := jc.d.dither_mode;
  except
    ReleaseContext(jc);
    raise;
  end;
end;

procedure TJPEGImage.Compress;
var
  LinesWritten, LinesPerCall: Integer;
  SrcScanLine: Pointer;
  PtrInc: Integer;
  jc: TJPEGContext;
  Src: TBitmap;
begin
  FillChar(jc, sizeof(jc), 0);
  jc.err := jpeg_std_error;
  jc.common.err := @jc.err;

  jpeg_CreateCompress(jc.c, JPEG_LIB_VERSION, sizeof(jc.c));
  try
    try
      jc.progress.progress_monitor := ProgressCallback;
      jc.progress.instance := Self;
      jc.common.progress := @jc.progress;

      FImage.Position := 0;
{$IFNDEF JPEGSO}
      jpeg_stdio_dest(jc.c, FImage);
{$ELSE}
      JPEGStdioDest(jc.c, FImage.FData);
{$ENDIF}

      if (FBitmap = nil) or (FBitmap.Width = 0) or (FBitmap.Height = 0) then Exit;
      jc.c.image_width := FBitmap.Width;
      jc.c.image_height := FBitmap.Height;
      jc.c.input_components := 3;           // JPEG requires 24bit RGB input
      jc.c.in_color_space := JCS_RGB;

      Src := TBitmap.Create;
      try
        Src.Assign(FBitmap);
        Src.PixelFormat := pf24bit;

        jpeg_set_defaults(jc.c);
        jpeg_set_quality(jc.c, FQuality, True);

        if FGrayscale then
        begin
          jpeg_set_colorspace(jc.c, JCS_GRAYSCALE);
        end;

        if ProgressiveEncoding then
          jpeg_simple_progression(jc.c);

        SrcScanline := Src.ScanLine[0];
        PtrInc := Integer(Src.ScanLine[1]) - Integer(SrcScanline);

          // if no dword padding required and source bitmap is top-down
        if (PtrInc > 0) and ((PtrInc and 3) = 0) then
          LinesPerCall := jc.c.image_height  // do whole bitmap in one call
        else
          LinesPerCall := 1;      // otherwise spoonfeed one row at a time

          jpeg_start_compress(jc.c, True);

          while (jc.c.next_scanline < jc.c.image_height) do
          begin
            LinesWritten := jpeg_write_scanlines(jc.c, @SrcScanline, LinesPerCall);
            Inc(Integer(SrcScanline), PtrInc * LinesWritten);
          end;

          jpeg_finish_compress(jc.c);
      finally
        Src.Free;
      end;
    except
      on EAbort do    // OnProgress can raise EAbort to cancel image save
    end;
  finally
    ReleaseContext(jc);
  end;
end;

function BuildPalette(const cinfo: jpeg_decompress_struct): HPalette;InLine;
var
  Pal: TMaxLogPalette;
  I: Integer;
  C: Byte;
begin
  Pal.palVersion := $300;
  Pal.palNumEntries := cinfo.actual_number_of_colors;
  if cinfo.out_color_space = JCS_GRAYSCALE then
    for I := 0 to Pal.palNumEntries-1 do
    begin
      C := cinfo.colormap^[0]^[I];
      Pal.palPalEntry[I].peRed := C;
      Pal.palPalEntry[I].peGreen := C;
      Pal.palPalEntry[I].peBlue := C;
      Pal.palPalEntry[I].peFlags := 0;
    end
  else
    for I := 0 to Pal.palNumEntries-1 do
    begin
      Pal.palPalEntry[I].peRed := cinfo.colormap^[2]^[I];
      Pal.palPalEntry[I].peGreen := cinfo.colormap^[1]^[I];
      Pal.palPalEntry[I].peBlue := cinfo.colormap^[0]^[I];
      Pal.palPalEntry[I].peFlags := 0;
    end;
  Result := CreatePalette(PLogPalette(@Pal)^);
end;

procedure BuildColorMap(var cinfo: jpeg_decompress_struct; P: HPalette);InLine;
var
  Pal: TMaxLogPalette;
  Count, I: Integer;
begin
  Count := GetPaletteEntries(P, 0, 256, Pal.palPalEntry);
  if Count = 0 then Exit;       // jpeg_destroy will free colormap
  cinfo.colormap := cinfo.common.mem.alloc_sarray(@cinfo.common, JPOOL_IMAGE, Count, 3);
  cinfo.actual_number_of_colors := Count;
  for I := 0 to Count-1 do
  begin
    Byte(cinfo.colormap^[2]^[I]) := Pal.palPalEntry[I].peRed;
    Byte(cinfo.colormap^[1]^[I]) := Pal.palPalEntry[I].peGreen;
    Byte(cinfo.colormap^[0]^[I]) := Pal.palPalEntry[I].peBlue;
  end;
end;

procedure TJPEGImage.Decompress;
var
  LinesPerCall, LinesRead: Integer;
{$IFDEF JPEGSO}
  DestScanLine, CurPixel: PChar;
  Swap: Char;
  AWidth: Integer;
{$ELSE}
  DestScanLine: PChar;
{$ENDIF}
  PtrInc: Integer;
  jc: TJPEGContext;
  GeneratePalette: Boolean;
begin
  GeneratePalette := True;

  InitDecompressor(Self, jc);
  try
    try
      // Set the bitmap pixel format
      FBitmap.Handle := 0;
      if jc.d.out_color_space = JCS_GRAYSCALE then
        FBitmap.PixelFormat := pf8bit
      else
        FBitmap.PixelFormat := pf24bit;

        jpeg_start_decompress(jc.d);

        // Set bitmap width and height
        with FBitmap do
        begin
          Handle := 0;
          Width := jc.d.output_width;
          Height := jc.d.output_height;
          DestScanline := ScanLine[0];
          PtrInc := Integer(ScanLine[1]) - Integer(DestScanline);
          if (PtrInc > 0) and ((PtrInc and 3) = 0) then
             // if no dword padding is required and output bitmap is top-down
            LinesPerCall := jc.d.rec_outbuf_height // read multiple rows per call
          else
            LinesPerCall := 1;            // otherwise read one row at a time
        end;

        if jc.d.buffered_image then
        begin  // decode progressive scans at low quality, high speed
          while jpeg_consume_input(jc.d) <> JPEG_REACHED_EOI do
          begin
            jpeg_start_output(jc.d, jc.d.input_scan_number);
            // extract color palette
            if (jc.common.progress^.completed_passes = 0) and (jc.d.colormap <> nil)
              and (FBitmap.PixelFormat = pf8bit) and GeneratePalette then
            begin
              FBitmap.Palette := BuildPalette(jc.d);
            end;
            DestScanLine := FBitmap.ScanLine[0];
            while (jc.d.output_scanline < jc.d.output_height) do
            begin
              LinesRead := jpeg_read_scanlines(jc.d, @DestScanline, LinesPerCall);
{$IFDEF JPEGSO}
              if PixelFormat = jf24bit then
              begin
                CurPixel := DestScanLine;
                AWidth := FBitmap.Width;
                while (CurPixel - DestScanLine) < (AWidth * 3) do
                begin
                  Swap := CurPixel[0];
                  CurPixel[0] := CurPixel[2];
                  CurPixel[2] := Swap;
                  Inc(CurPixel, 3);
                end;
              end;
{$ENDIF}
              Inc(Integer(DestScanline), PtrInc * LinesRead);
            end;
            jpeg_finish_output(jc.d);
          end;
          // reset options for final pass at requested quality
          jc.d.dct_method := jc.FinalDCT;
          jc.d.dither_mode := jc.FinalDitherMode;
          if jc.FinalTwoPassQuant then
          begin
            jc.d.two_pass_quantize := True;
            jc.d.colormap := nil;
          end;
          jpeg_start_output(jc.d, jc.d.input_scan_number);
          DestScanLine := FBitmap.ScanLine[0];
        end;

        // build final color palette
        if (not jc.d.buffered_image or jc.FinalTwoPassQuant) and
          (jc.d.colormap <> nil) and GeneratePalette then
        begin
          FBitmap.Palette := BuildPalette(jc.d);
          DestScanLine := FBitmap.ScanLine[0];
        end;
        // final image pass for progressive, first and only pass for baseline
        while (jc.d.output_scanline < jc.d.output_height) do
        begin
          LinesRead := jpeg_read_scanlines(jc.d, @DestScanline, LinesPerCall);
{$IFDEF JPEGSO}
          if PixelFormat = jf24bit then
          begin
            CurPixel := DestScanLine;
            AWidth := FBitmap.Width;
            while (CurPixel - DestScanLine) < (AWidth * 3) do
            begin
              Swap := CurPixel[0];
              CurPixel[0] := CurPixel[2];
              CurPixel[2] := Swap;
              Inc(CurPixel, 3);
            end;
          end;
{$ENDIF}
          Inc(Integer(DestScanline), PtrInc * LinesRead);
        end;

        if jc.d.buffered_image then jpeg_finish_output(jc.d);
        jpeg_finish_decompress(jc.d);
    except
      on EAbort do ;   // OnProgress can raise EAbort to cancel image load
    end;
  finally
    ReleaseContext(jc);
  end;
end;

end.


