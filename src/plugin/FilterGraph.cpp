/*
  ==============================================================================

   This file is part of the JUCE library - "Jules' Utility Class Extensions"
   Copyright 2004-9 by Raw Material Software Ltd.

  ------------------------------------------------------------------------------

   JUCE can be redistributed and/or modified under the terms of the GNU General
   Public License (Version 2), as published by the Free Software Foundation.
   A copy of the license is included in the JUCE distribution, or can be found
   online at www.gnu.org/licenses.

   JUCE is distributed in the hope that it will be useful, but WITHOUT ANY
   WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
   A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

  ------------------------------------------------------------------------------

   To release a closed-source product which uses JUCE, commercial licenses are
   available: visit www.rawmaterialsoftware.com/juce for more information.

  ==============================================================================
*/
// Authors: Nicholas J. Bryan, Original Author: Julian Storer
#include "../JuceLibraryCode/JuceHeader.h"
#include "MainHostWindow.h"
#include "FilterGraph.h"
#include "GraphEditorPanel.h"

#include "../Main.h"


//==============================================================================
FilterConnection::FilterConnection (FilterGraph& owner_)
    : owner (owner_)
{
}

FilterConnection::FilterConnection (const FilterConnection& other)
    : sourceFilterID (other.sourceFilterID),
      sourceChannel (other.sourceChannel),
      destFilterID (other.destFilterID),
      destChannel (other.destChannel),
      owner (other.owner)
{
}

FilterConnection::~FilterConnection()
{
}

//==============================================================================
const int FilterGraph::midiChannelNumber = 0x1000;

 

FilterGraph::FilterGraph (AudioPluginFormatManager& formatManager_)
: FileBasedDocument (filenameSuffix,
                     filenameWildcard,
                     "Load a filter graph",
                     "Save a filter graph"),
            formatManager (formatManager_),
            lastUID (0)
{
    setChangedFlag (false);
}

FilterGraph::~FilterGraph()
{
    graph.clear();
}

uint32 FilterGraph::getNextUID() noexcept
{
    return ++lastUID;
}

//==============================================================================
int FilterGraph::getNumFilters() const noexcept
{
    return graph.getNumNodes();
}

const AudioProcessorGraph::Node::Ptr FilterGraph::getNode (const int index) const noexcept
{
    return graph.getNode (index);
}

const AudioProcessorGraph::Node::Ptr FilterGraph::getNodeForId (const uint32 uid) const noexcept
{
    return graph.getNodeForId (NodeID (uid));
}

void FilterGraph::addFilter ( AudioPluginInstance* instance, double x, double y)
{
    
    AudioProcessorGraph::Node* node = nullptr;
    if (instance != nullptr)
        node = graph.addNode (instance);
    
    if (node != nullptr)
    {
        node->properties.set ("x", x);
        node->properties.set ("y", y);
        changed();
    }
 
}

void FilterGraph::addFilter (const PluginDescription* desc, double x, double y)
{
    if (desc != nullptr)
    {
        String errorMessage;

        AudioPluginInstance* instance = formatManager.createPluginInstance (*desc, 44100, 250, errorMessage);

        AudioProcessorGraph::Node* node = nullptr;

        if (instance != nullptr)
            node = graph.addNode (instance);

        if (node != nullptr)
        {
            node->properties.set ("x", x);
            node->properties.set ("y", y);
            changed();
        }
        else
        {
            AlertWindow::showMessageBox (AlertWindow::WarningIcon,
                                         TRANS("Couldn't create filter"),
                                         errorMessage);
        }
    }
}

void FilterGraph::removeFilter (const uint32 id)
{
    PluginWindow::closeCurrentlyOpenWindowsFor (id);

    if (graph.removeNode (NodeID (id)))
        changed();
}

void FilterGraph::disconnectFilter (const uint32 id)
{
    if (graph.disconnectNode (NodeID (id)))
        changed();
}

void FilterGraph::removeIllegalConnections()
{
    if (graph.removeIllegalConnections())
        changed();
}

void FilterGraph::setNodePosition (const int nodeID, double x, double y)
{
    const AudioProcessorGraph::Node::Ptr n (graph.getNodeForId (NodeID (nodeID)));

    if (n != nullptr)
    {
        n->properties.set ("x", jlimit (0.0, 1.0, x));
        n->properties.set ("y", jlimit (0.0, 1.0, y));
    }
}

void FilterGraph::getNodePosition (const int nodeID, double& x, double& y) const
{
    x = y = 0;

    const AudioProcessorGraph::Node::Ptr n (graph.getNodeForId (NodeID (nodeID)));

    if (n != nullptr)
    {
        x = (double) n->properties ["x"];
        y = (double) n->properties ["y"];
    }
}

//==============================================================================
std::vector<AudioProcessorGraph::Connection> FilterGraph::getConnections() const
{
    return graph.getConnections();
}

/*
int FilterGraph::getNumConnections() const noexcept
{
    return graph.getNumConnections();
}

const AudioProcessorGraph::Connection* FilterGraph::getConnection (const int index) const noexcept
{
    return graph.getConnection (index);
}

const AudioProcessorGraph::Connection* FilterGraph::getConnectionBetween (uint32 sourceFilterUID,
                                                                          int sourceFilterChannel,
                                                                          uint32 destFilterUID,
                                                                          int destFilterChannel) const noexcept
{
    return graph.getConnectionBetween (sourceFilterUID, sourceFilterChannel,
                                       destFilterUID, destFilterChannel);
}
*/

bool FilterGraph::canConnect (uint32 sourceFilterUID, int sourceFilterChannel,
                              uint32 destFilterUID, int destFilterChannel) const noexcept
{
    AudioProcessorGraph::NodeAndChannel source;
    source.nodeID = NodeID (sourceFilterUID);
    source.channelIndex = sourceFilterChannel;

    AudioProcessorGraph::NodeAndChannel destination;
    destination.nodeID = NodeID (destFilterUID);
    destination.channelIndex = destFilterChannel;

    return graph.canConnect (AudioProcessorGraph::Connection (source, destination));
}

bool FilterGraph::addConnection (uint32 sourceFilterUID, int sourceFilterChannel,
                                 uint32 destFilterUID, int destFilterChannel)
{
    AudioProcessorGraph::NodeAndChannel source;
    source.nodeID = NodeID (sourceFilterUID);
    source.channelIndex = sourceFilterChannel;

    AudioProcessorGraph::NodeAndChannel destination;
    destination.nodeID = NodeID (destFilterUID);
    destination.channelIndex = destFilterChannel;

    const bool result = graph.addConnection (AudioProcessorGraph::Connection (source, destination));

    if (result)
        changed();

    return result;
}

/*
void FilterGraph::removeConnection (const int index)
{
    graph.removeConnection (index);
    changed();
}
*/

void FilterGraph::removeConnection (uint32 sourceFilterUID, int sourceFilterChannel,
                                    uint32 destFilterUID, int destFilterChannel)
{
    AudioProcessorGraph::NodeAndChannel source;
    source.nodeID = NodeID (sourceFilterUID);
    source.channelIndex = sourceFilterChannel;

    AudioProcessorGraph::NodeAndChannel destination;
    destination.nodeID = NodeID (destFilterUID);
    destination.channelIndex = destFilterChannel;

    if (graph.removeConnection (AudioProcessorGraph::Connection (source, destination)))
        changed();
}

bool FilterGraph::isConnected (uint32 sourceFilterUID, int sourceFilterChannel,
                               uint32 destFilterUID, int destFilterChannel) const noexcept
{
    AudioProcessorGraph::NodeAndChannel source;
    source.nodeID = NodeID (sourceFilterUID);
    source.channelIndex = sourceFilterChannel;

    AudioProcessorGraph::NodeAndChannel destination;
    destination.nodeID = NodeID (destFilterUID);
    destination.channelIndex = destFilterChannel;

    return graph.isConnected (AudioProcessorGraph::Connection (source, destination));
}

void FilterGraph::clear()
{
    PluginWindow::closeAllCurrentlyOpenWindows();

    graph.clear();
    changed();
}

//==============================================================================
String FilterGraph::getDocumentTitle()
{
    if (! getFile().exists())
        return "Unnamed";

    return getFile().getFileNameWithoutExtension();
}

Result FilterGraph::loadDocument (const File& file)
{
    XmlDocument doc (file);
    ScopedPointer<XmlElement> xml (doc.getDocumentElement());

    if (xml == nullptr || ! xml->hasTagName ("FILTERGRAPH"))
        return Result::fail ("Not a valid filter graph file");

    restoreFromXml (*xml);
    return Result::ok();
}

Result FilterGraph::saveDocument (const File& file)
{
    ScopedPointer<XmlElement> xml (createXml());

    if (! xml->writeToFile (file, String()))
        return Result::fail ("Couldn't write to the file");

    return Result::ok();
}

File FilterGraph::getLastDocumentOpened()
{
     
    RecentlyOpenedFilesList recentFiles;
    recentFiles.restoreFromString (MAIN_APP->appProperties->getUserSettings()
                                        ->getValue ("recentFilterGraphFiles"));

    return recentFiles.getFile (0);
}

void FilterGraph::setLastDocumentOpened (const File& file)
{
    
    RecentlyOpenedFilesList recentFiles;
    recentFiles.restoreFromString (MAIN_APP->appProperties->getUserSettings()
                                        ->getValue ("recentFilterGraphFiles"));

    recentFiles.addFile (file);

    MAIN_APP->appProperties->getUserSettings()
        ->setValue ("recentFilterGraphFiles", recentFiles.toString());
}

//==============================================================================
static XmlElement* createNodeXml (AudioProcessorGraph::Node* const node) noexcept
{
    AudioPluginInstance* plugin = dynamic_cast <AudioPluginInstance*> (node->getProcessor());

    if (plugin == nullptr)
    {
        jassertfalse;
        return nullptr;
    }

    XmlElement* e = new XmlElement ("FILTER");
    e->setAttribute ("uid", (int) node->nodeID.uid);
    e->setAttribute ("x", node->properties ["x"].toString());
    e->setAttribute ("y", node->properties ["y"].toString());
    e->setAttribute ("uiLastX", node->properties ["uiLastX"].toString());
    e->setAttribute ("uiLastY", node->properties ["uiLastY"].toString());

    PluginDescription pd;
    plugin->fillInPluginDescription (pd);

    e->addChildElement (pd.createXml());

    XmlElement* state = new XmlElement ("STATE");

    MemoryBlock m;
    node->getProcessor()->getStateInformation (m);
    state->addTextElement (m.toBase64Encoding());
    e->addChildElement (state);

    return e;
}

void FilterGraph::createNodeFromXml (const XmlElement& xml)
{
    PluginDescription pd;

    forEachXmlChildElement (xml, e)
    {
        if (pd.loadFromXml (*e))
            break;
    }

    String errorMessage;

    // TODO:
    AudioPluginInstance* instance = formatManager.createPluginInstance (pd, 44100, 256,errorMessage);

    if (instance == nullptr)
    {
        // xxx handle ins + outs
    }

    if (instance == nullptr)
        return;

    AudioProcessorGraph::Node::Ptr node (graph.addNode (instance, NodeID (xml.getIntAttribute ("uid"))));

    const XmlElement* const state = xml.getChildByName ("STATE");

    if (state != nullptr)
    {
        MemoryBlock m;
        m.fromBase64Encoding (state->getAllSubText());

        node->getProcessor()->setStateInformation (m.getData(), (int) m.getSize());
    }

    node->properties.set ("x", xml.getDoubleAttribute ("x"));
    node->properties.set ("y", xml.getDoubleAttribute ("y"));
    node->properties.set ("uiLastX", xml.getIntAttribute ("uiLastX"));
    node->properties.set ("uiLastY", xml.getIntAttribute ("uiLastY"));
}

XmlElement* FilterGraph::createXml() const
{
    XmlElement* xml = new XmlElement ("FILTERGRAPH");

    int i;
    for (i = 0; i < graph.getNumNodes(); ++i)
    {
        xml->addChildElement (createNodeXml (graph.getNode (i)));
    }

    const std::vector<AudioProcessorGraph::Connection> connections =
        graph.getConnections();
    for (i = 0; i < connections.size(); ++i)
    {
        const AudioProcessorGraph::Connection& fc = connections[i];

        XmlElement* e = new XmlElement ("CONNECTION");

        e->setAttribute ("srcFilter", (int) fc.source.nodeID.uid);
        e->setAttribute ("srcChannel", fc.source.channelIndex);
        e->setAttribute ("dstFilter", (int) fc.destination.nodeID.uid);
        e->setAttribute ("dstChannel", fc.destination.channelIndex);

        xml->addChildElement (e);
    }

    return xml;
}

void FilterGraph::restoreFromXml (const XmlElement& xml)
{
    clear();

    forEachXmlChildElementWithTagName (xml, e, "FILTER")
    {
        createNodeFromXml (*e);
        changed();
    }

    forEachXmlChildElementWithTagName (xml, e, "CONNECTION")
    {
        addConnection ((uint32) e->getIntAttribute ("srcFilter"),
                       e->getIntAttribute ("srcChannel"),
                       (uint32) e->getIntAttribute ("dstFilter"),
                       e->getIntAttribute ("dstChannel"));
    }

    graph.removeIllegalConnections();
}
