#ifndef H_SPINNER_PHYSICS_PROPERTY
#define H_SPINNER_PHYSICS_PROPERTY

class SpinnerPhysicsProperty: public BasePropertyDialog
{
public:
    SpinnerPhysicsProperty(VectorProtected<ISelect> *pvsel);
    virtual ~SpinnerPhysicsProperty()
    {
    }

    void UpdateVisuals(const int dispid=-1);
    void UpdateProperties(const int dispid);

protected:
    virtual BOOL OnInitDialog();

private:
    EditBox m_dampingEdit;
    EditBox m_elasticityEdit;
};
#endif
