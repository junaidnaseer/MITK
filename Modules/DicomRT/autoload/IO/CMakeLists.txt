MITK_CREATE_MODULE(DicomRTIO
  INCLUDE_DIRS
    PRIVATE src/IO
  DEPENDS
    PUBLIC MitkDicomRT MitkContourModel
  PACKAGE_DEPENDS PUBLIC DCMTK
  AUTOLOAD_WITH MitkCore
)
