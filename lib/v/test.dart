import 'package:aila/core/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TestPage extends HookConsumerWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('test'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFF1F5FB),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                //列表内容少的时候靠上
                alignment: Alignment.topCenter,
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 1.0.sw,
                      height: 50.h,
                      child: Container(
                        color: Colors.green,
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(15, 10, 0, 10),
                      constraints: BoxConstraints(
                        maxHeight: 100.0,
                        minHeight: 50.0,
                      ),
                      decoration: BoxDecoration(
                          color: Color(0xFFF5F6FF),
                          borderRadius: BorderRadius.all(Radius.circular(2))),
                      child: TextField(
                        // controller: textEditingController,
                        cursorColor: Color(0xFF464EB5),
                        maxLines: null,
                        maxLength: 200,
                        decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 10.0, bottom: 10.0),
                          hintText: "回复",
                          hintStyle:
                              TextStyle(color: Color(0xFFADB3BA), fontSize: 15),
                        ),
                        style:
                            TextStyle(color: Color(0xFF03073C), fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom,
            ),
          ],
        ),
      ),
      // SingleChildScrollView(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.end,
      //     children: [
      //       Container(
      //         width: double.infinity,
      //         height: 700,
      //         color: Colors.orange,
      //       ),
      //       TextField(
      //         decoration: InputDecoration(labelText: "Type something"),
      //         scrollPadding: EdgeInsets.only(
      //             bottom: MediaQuery.of(context).viewInsets.bottom + 40.0),
      //       ),
      // SizedBox(
      //   height: MediaQuery.of(context).viewInsets.bottom,
      // ),
      //     ],
      //   ),
      // ),
    );
  }
}
