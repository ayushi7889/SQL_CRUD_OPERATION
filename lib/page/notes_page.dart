import 'package:flutter/material.dart';
import 'package:sqlcrud/db/notes_db.dart';
import 'package:sqlcrud/model/note.dart';
import 'package:sqlcrud/page/add_edit_note_page.dart';
import 'package:sqlcrud/page/note_detail_page.dart';
import 'package:sqlcrud/widget/note_card_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late List<Note> notes;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  @override
  void dispose() {
    NotesDatabase.instance.close();
    super.dispose();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);

    // ignore: unnecessary_this
    this.notes = await NotesDatabase.instance.readAllNotes();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) =>
     Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notes',
          style: TextStyle(fontSize: 24),
        ),

        // ignore: prefer_const_literals_to_create_immutables
        actions: [const Icon(Icons.search), const SizedBox(width: 12)],
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : notes.isEmpty
                ? Text(
                    'No Notes',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  )
                : buildNotes(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditNotePage()),
          );
          refreshNotes();
        },
      ),
    );

    
    buildNotes() => StaggeredGridView.countBuilder(
          padding: const EdgeInsets.all(8),
          itemCount: notes.length,
          staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          itemBuilder: (context, index) {
            final note = notes[index];
            return GestureDetector(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NoteDetailPage(noteId: note.id!),
                ));
                refreshNotes();
              },
              child: NoteCardWidget(note: note, index: index),
            );
          },
        );
  
}
