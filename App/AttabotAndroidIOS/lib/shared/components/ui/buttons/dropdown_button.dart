import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class CustomDropdown extends StatefulWidget {
  final int? selectedValue;
  final List<int> options;
  final ValueChanged<int?> onChanged;
  final String suffix;
  final String placeholder;
  final bool autoOpen;

  const CustomDropdown({
    super.key,
    this.selectedValue,
    required this.options,
    required this.onChanged,
    this.suffix = '',
    this.placeholder = '',
    this.autoOpen = false,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final Color _dropdownAccentColor = mediumBlueGray;
  final Color _dropdownBackgroundColor = darkBlueGray;
  final Color _textColor = neutralWhite;

  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _menuEntry;
  OverlayEntry? _backdropEntry;
  bool _isOpen = false;
  bool _autoOpened = false;

  @override
  void dispose() {
    _removeOverlay(notifyState: false);
    super.dispose();
  }

  // for auto-opening the dropdown in help dialog
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.autoOpen && !_autoOpened && widget.options.isNotEmpty && !_isOpen) {
        _autoOpened = true;
        _showOverlay();
      }
    });
  }

  void _toggleDropdown() {
    if (widget.options.isEmpty) return;
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _removeOverlay({bool notifyState = true}) {
    _menuEntry?.remove();
    _backdropEntry?.remove();
    _menuEntry = null;
    _backdropEntry = null;
    if (notifyState && mounted) {
      setState(() {
        _isOpen = false;
      });
    } else {
      _isOpen = false;
    }
  }

  void _showOverlay() {
    if (!mounted || _isOpen || widget.options.isEmpty) return;
    final overlay = Overlay.of(context);
    final RenderBox? overlayBox = overlay.context.findRenderObject() as RenderBox?;

    final RenderBox? box = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final Size size = box.size;
    final Offset offset = overlayBox != null
        ? box.localToGlobal(Offset.zero, ancestor: overlayBox)
        : box.localToGlobal(Offset.zero);


      _backdropEntry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _removeOverlay,
          child: const SizedBox.shrink(),
        ),
      ),
    );

    // Dropdown menu entry
      _menuEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height - 1, // slight overlap 
        width: size.width,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(maxHeight: 240),
            decoration: BoxDecoration(
              color: _dropdownBackgroundColor,
              borderRadius: BorderRadius.circular(2),
              border: const Border(
                left: BorderSide(color: mediumBlueGray, width: 1.5),
                right: BorderSide(color: mediumBlueGray, width: 1.5),
                bottom: BorderSide(color: mediumBlueGray, width: 1.5),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.options.length, (index) {
                    final int e = widget.options[index];
                    final bool isSelected = widget.selectedValue != null && e == widget.selectedValue;
                    final bool isLast = index == widget.options.length - 1;
                    return InkWell(
                      onTap: () {
                        widget.onChanged(e);
                        _removeOverlay();
                      },
                      child: Container(
                        height: 36,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? mediumBlueGray : Colors.transparent,
                          border: isLast
                              ? null
                              : const Border(
                                  bottom: BorderSide(
                                    color: mediumBlueGray,
                                    width: 1.5,
                                  ),
                                ),
                        ),
                        child: Text(
                          "$e${widget.suffix}",
                          style: TextStyle(
                            color: _textColor,
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insertAll([_backdropEntry!, _menuEntry!]);
    if (mounted) {
      setState(() {
        _isOpen = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.shortestSide >= 600;
    final double containerHeight = isTablet ? 40 : 16;
    final double containerWidth = isTablet ? 110 : 66;
    final double fontSize = isTablet ? 16 : 12;
    final double iconSize = isTablet ? 22 : 16;
    final double borderRadius = isTablet ? 12 : 5;
    final EdgeInsets padding = EdgeInsets.symmetric(horizontal: isTablet ? 12 : 8, vertical: isTablet ? 4 : 0);

    return Container(
      key: _buttonKey,
      height: containerHeight,
      width: containerWidth,
      decoration: BoxDecoration(
        color: _dropdownAccentColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: _toggleDropdown,
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.selectedValue != null
                      ? "${widget.selectedValue}${widget.suffix}"
                      : widget.placeholder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: neutralWhite,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize,
                    fontStyle: widget.selectedValue == null ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 10 : 6),
              Icon(
                Icons.expand_more,
                color: neutralDarkBlueAD,
                size: iconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
