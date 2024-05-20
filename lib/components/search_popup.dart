import 'package:flutter/material.dart';

class SearchPopup extends StatefulWidget {
  final List<String> filteredEntities;
  final String hintText;

  const SearchPopup(
      {Key? key, required this.filteredEntities, required this.hintText})
      : super(key: key);

  @override
  _SearchPopupState createState() => _SearchPopupState();
}

class _SearchPopupState extends State<SearchPopup> {
  TextEditingController searchController = TextEditingController();
  String? selectedEntityName;
  List<String> searchResults = [];

  @override
  void initState() {
    super.initState();
    searchResults = widget.filteredEntities;
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      setState(() {
        searchResults = widget.filteredEntities
            .where((charity) =>
                charity.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    } else {
      setState(() {
        searchResults = widget.filteredEntities;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(20.0),
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return true;
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8 + 45,
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    filterSearchResults(value);
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        searchResults[index],
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context, searchResults[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
