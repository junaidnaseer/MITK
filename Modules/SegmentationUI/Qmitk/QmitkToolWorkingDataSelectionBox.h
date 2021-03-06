/*============================================================================

The Medical Imaging Interaction Toolkit (MITK)

Copyright (c) German Cancer Research Center (DKFZ)
All rights reserved.

Use of this source code is governed by a 3-clause BSD license that can be
found in the LICENSE file.

============================================================================*/

#ifndef QmitkToolWorkingDataSelectionListBox_h_Included
#define QmitkToolWorkingDataSelectionListBox_h_Included

// mmueller
#include <MitkSegmentationUIExports.h>
#include <QListWidget>

#include "mitkProperties.h"
#include "mitkToolManager.h"

/**
\brief Display the data selection of a ToolManager.

\sa mitk::ToolManager
\sa mitk::DataStorage

\ingroup Widgets

Shows the working data of a ToolManager in a segmentation setting. By default only the segmentation name is shown.

The working images (segmentations) are listed in a QListView, each row telling the color and name
of a single segmentation. One or several segmentations can be selected to be the "active" segmentations.

$Author: maleike $
*/

class MITKSEGMENTATIONUI_EXPORT QmitkToolWorkingDataSelectionBox : public QListWidget
{
  Q_OBJECT

public:
  /**
  * \brief What kind of items should be displayed.
  *
  * Every mitk::Tool holds a NodePredicateBase object, telling the kind of data that this
  * tool will successfully work with. There are two ways that this list box deals with
  * these predicates.
  *
  *   DEFAULT is: list data if ANY one of the displayed tools' predicate matches.
  * Other option: list data if ALL one of the displayed tools' predicate matches
  */
  enum DisplayMode
  {
    ListDataIfAllToolsMatch,
    ListDataIfAnyToolMatches
  };

  QmitkToolWorkingDataSelectionBox(QWidget *parent = nullptr);
  ~QmitkToolWorkingDataSelectionBox() override;

  mitk::DataStorage *GetDataStorage();
  void SetDataStorage(mitk::DataStorage &storage);

  /**
  \brief Can be called to trigger an update of the list contents.
  */
  void UpdateDataDisplay();

  /**
  \brief Returns the associated mitk::ToolManager.
  */
  mitk::ToolManager *GetToolManager();

  /**
  \brief Tell this object to listen to another ToolManager.
  */
  void SetToolManager(mitk::ToolManager &); // no nullptr pointer allowed here, a manager is required

  /**
  * \brief A list of all displayed DataNode objects.
  * This method might be convenient for program modules that want to display
  * additional information about these nodes, like a total volume of all segmentations, etc.
  */
  mitk::ToolManager::DataVectorType GetAllNodes(bool onlyDerivedFromOriginal = true);

  /**
  * \brief A list of all selected DataNode objects.
  * This method might be convenient for program modules that want to display
  * additional information about these nodes, like a total volume of all segmentations, etc.
  */
  mitk::ToolManager::DataVectorType GetSelectedNodes();

  /**
  * \brief Like GetSelectedNodes(), but will only return one object.
  * Will only return what QListView gives as selected object (documentation says nothing is returned if list is in
  * Single selection mode).
  */
  mitk::DataNode *GetSelectedNode();

  /**
  * \brief Callback function, no need to call it.
  * This is used to observe and react to changes in the mitk::ToolManager object.
  */
  void OnToolManagerWorkingDataModified();

  /**
  * \brief Callback function, no need to call it.
  * This is used to observe and react to changes in the mitk::ToolManager object.
  */
  void OnToolManagerReferenceDataModified();

signals:

  void WorkingNodeSelected(const mitk::DataNode *);

protected slots:

  void OnWorkingDataSelectionChanged();

protected:
  typedef std::map<QListWidgetItem *, mitk::DataNode *> ItemNodeMapType;

  mitk::ToolManager::Pointer m_ToolManager;

  ItemNodeMapType m_Node;

  bool m_SelfCall;

  mitk::DataNode *m_LastSelectedReferenceData;

  std::string m_ToolGroupsForFiltering;

  bool m_DisplayOnlyDerivedNodes;
};

#endif
