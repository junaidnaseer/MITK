/*===================================================================

The Medical Imaging Interaction Toolkit (MITK)

Copyright (c) German Cancer Research Center,
Division of Medical and Biological Informatics.
All rights reserved.

This software is distributed WITHOUT ANY WARRANTY; without
even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE.

See LICENSE.txt or http://www.mitk.org for details.

===================================================================*/

#include "mitkAnnotationPlacer.h"
#include "mitkBaseRenderer.h"

#include <mitkVtkLayerController.h>
#include "mitkOverlay2DLayouter.h"
#include "mitkAnnotationService.h"

namespace mitk
{


AnnotationPlacer::~AnnotationPlacer()
{
}

void AnnotationPlacer::RegisterAnnotationRenderer(const std::string &rendererID)
{
  AnnotationService::RegisterAnnotationRenderer<AnnotationPlacer>(rendererID);
}


}
