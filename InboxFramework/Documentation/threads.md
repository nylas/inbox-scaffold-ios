Displaying Unread Threads
=========================

Inbox makes it easy to display threads, messages, contacts and other information from the user's mailbox. To fetch Inbox objects, you use an instance of an INModelProvider, which wraps underlying calls to the local cache, the Inbox API, and the Inbox realtime service (coming soon) to provide you with the view you want.

`INModelProvider` is somewhat similar to Core Data's `NSManagedResultsController` and YapDatabase's concept of "Views". The goal is to make it easy to build rich, realtime views of the user's mail and hide the complexity behind retrieving objects, which could come from a cache, be streamed via a socket connection, or fetched via the API.

To display data, your application needs to:

- Create and configure an INModelProvider
- Implement the INModelProviderDelegate protocol

Creating and Configuring an INModelProvider
------

Here's an example that shows how to create and configure a model provider for displaying unread threads:

    // fetch a namespace, which represents a particular email address our auth token provides access to.
    INNamespace * namespace = [[[INAPIManager shared] namespaces] firstObject];

    // create a new thread provider for displaying threads in that namespace
    INThreadProvider * provider = [namespace newThreadProvider];

    // configure the provider to display only unread threads using an NSPredicate
    [provider setItemFilterPredicate: [NSComparisonPredicate predicateWithFormat: @"ANY tagIDs = %@", INTagIDUnread]];

    // configure the provider to sort items by their last message date
    [provider setItemSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastMessageDate" ascending:NO]]];

    // start monitoring the provider for data
    [provider setDelegate: self];


Once you've created a provider, you can configure it by providing an NSPredicate. In the example above, we use a predicate to limit our view to threads matching "ANY tagIDs = 'unread'". The Inbox framework uses `NSPredicate` extensively. Under the hood, the predicates are translated into filter parameters for API calls, and into SQL WHERE clauses for retrieving cached data. The predicate is applied to objects as they change, so marking a thread as 'read' automatically triggers that thread to be removed from your provider's displayed set.

Note: `NSCompoundPredicates` are supported, but only AND predicates can be used at this time. Comparison predicates can filter based on a variety of properties, but not all of them. For example, you can't filter messages based on message body. See the documentation for INThread, INMessage, etc. to see which properties you can use in prediates. For advanced filtering, check out the Inbox search API.

Similarly, INModelProvider uses sort descriptors to order the models it provides. You can specify one or more sort descriptors to order data in your view.


Implementing the INModelProviderDelegate protocol
------

INModelProvider defines several delegate methods that you should implement to display your view's data. Though you can access the provider's result set directly using the -items method, the items being displayed may change at any time and there may not be items to display immediately after the provider is created. Your view should implement the delegate protocol and update to reflect changes as they happen.

Here's an example of a typical provider delegate implementation:

    /* Called when the items array of the provider has changed substantially. You should
     refresh your interface completely to reflect the new items array. */

    - (void)providerDataChanged:(INModelProvider*)provider
    {
        [_tableView reloadData];
    }

    /* Called when objects have been added, removed, or modified in the items array, usually
     as a result of new data being fetched from the Inbox API or published on a real-time
     connection. You may choose to refresh your interface completely or apply the individual
     changes provided in the changeSet. */

    - (void)provider:(INModelProvider*)provider dataAltered:(INModelProviderChangeSet *)changeSet
    {
        [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:[changeSet indexPathsFor: INModelProviderChangeRemove] withRowAnimation:UITableViewRowAnimationLeft];
        [_tableView insertRowsAtIndexPaths:[changeSet indexPathsFor: INModelProviderChangeAdd] withRowAnimation:UITableViewRowAnimationTop];
        [_tableView endUpdates];
        [_tableView reloadRowsAtIndexPaths:[changeSet indexPathsFor: INModelProviderChangeUpdate] withRowAnimation:UITableViewRowAnimationNone];
    }

    /* Called when an attempt to load data from the Inbox API has failed. If you requested
     the fetch by calling -refresh on the model provider or modifying the sort descriptors
     or filter predicate, you may want to display the error provided. */

    - (void)provider:(INModelProvider*)provider dataFetchFailed:(NSError *)error
    {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }

    /** Called when the provider has fully refresh in response to an explicit refresh request
     or a change in the item filter predicate or sort descriptors. */
    - (void)providerDataFetchCompleted:(INModelProvider*)provider
    {
        // hide refresh UI
    }


